// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/escrow/Escrow.sol";

import "./Structs.sol";

//? maybe add roles
//todo nfts URIs

contract Event is Ownable, ERC721, ERC721Enumerable {
    using Address for address payable;
    using BitMaps for BitMaps.BitMap;
    using EnumerableSet for EnumerableSet.AddressSet;

    /* types */

    enum EventState {
        Online,
        Offline
    }

    // enum Roles {
    //     Admin,
    //     Validator
    // }

    struct TicketState {
        bool validated;
        address validator;
    }

    /* variables */

    Escrow private immutable i_escrow;
    Structs.TicketchainConfig private i_ticketchainConfig;
    Structs.Package[] private i_packages;
    Structs.EventConfig private _eventConfig;
    EnumerableSet.AddressSet private _validators;

    bool private _internalTransfer;
    bool private _eventCanceled;
    mapping(uint => TicketState) private _ticketsState;

    /* events */

    event Buy(
        address indexed user,
        address indexed to,
        uint indexed ticket,
        uint value
    );
    event Gift(address indexed user, address indexed to, uint indexed ticket);
    event Refund(address indexed user, uint indexed ticket, uint value);
    event ApproveValidator(
        address indexed user,
        address indexed validator,
        uint indexed ticket
    );
    event ValidateTicket(address indexed validator, uint indexed ticket);
    event CancelEvent();

    event AddValidator(address indexed validator);
    event RemoveValidator(address indexed validator);
    event EventConfigChange(Structs.EventConfig indexed eventConfig);

    /* errors */

    error NoTickets();
    error NotValidator(address user);
    error NothingToWithdraw();
    error InvalidInputs();

    error EventOnline();
    error EventOffline();
    error NoRefund();
    error EventCanceled();

    error TicketDoesNotExist(uint ticket);
    error UserNotTicketOwner(address user, uint ticket);
    error ValidatorNotApproved(address validator, uint ticket);
    error TicketAlreadyValidated(uint ticket, address validator);

    error WrongValue(uint current, uint expected);

    /* constructor */

    constructor(
        address owner,
        Structs.ERC721Config memory erc721Config,
        Structs.Percentage memory feePercentage
    ) ERC721(erc721Config.name, erc721Config.symbol) {
        i_escrow = new Escrow();

        i_ticketchainConfig = Structs.TicketchainConfig(
            msg.sender,
            feePercentage
        );

        transferOwnership(owner);
    }

    /* modifiers */

    modifier checkValidator(address validator) {
        if (!_validators.contains(validator)) revert NotValidator(validator);
        _;
    }

    modifier internalTransfer() {
        _internalTransfer = true;
        _;
        _internalTransfer = false;
    }

    /* owner */

    function withdrawProfit() external onlyOwner {
        if (block.timestamp < _eventConfig.end) revert EventOnline();

        if (address(this).balance == 0) revert NothingToWithdraw();
        //todo get from escrow
        // payable(owner()).sendValue(address(this).balance);
    }

    // function deployTickets(
    //     address to,
    //     Structs.Package[] memory packages
    // ) external onlyOwner {
    //     uint totalSupply = getTicketSupply();

    //     for (uint i; i < packages.length; i++) {
    //         for (uint j; j < packages[i].supply; j++)
    //             _safeMint(to, totalSupply + j);

    //         i_packages.push(packages[i]);
    //     }
    // }

    //! probably won't work for LOTS of users
    function cancelEvent() external onlyOwner {
        for (uint i; i < totalSupply(); i++) {
            uint ticket = tokenByIndex(i);
            address user = ownerOf(ticket);

            //? _burn(tokenByIndex(i)); // internalTransfer

            uint price = getTicketPrice(ticket);
            if (price != 0)
                i_escrow.deposit{
                    value: price -
                        _getPercentage(price, i_ticketchainConfig.feePercentage)
                }(user);
        }

        if (address(this).balance != 0)
            i_escrow.deposit{value: address(this).balance}(owner());

        // cancel only after burning tokens
        _eventCanceled = true;

        emit CancelEvent();
    }

    /* validator */

    function validateTickets(
        uint[] memory tickets
    ) external checkValidator(msg.sender) {
        for (uint i; i < tickets.length; i++) {
            uint ticket = tickets[i];

            // check if ticket is validated
            _checkTicketValidated(ticket);

            if (_ticketsState[ticket].validator != msg.sender)
                revert ValidatorNotApproved(msg.sender, ticket);

            _ticketsState[ticket].validated = true;

            emit ValidateTicket(msg.sender, ticket);
        }
    }

    /* user */

    function approveTickets(
        uint[] memory tickets,
        address validator
    ) external checkValidator(validator) {
        for (uint i; i < tickets.length; i++) {
            uint ticket = tickets[i];

            // check if ticket is validated
            _checkTicketValidated(ticket);

            // check if user is ticket owner
            _checkTicketOwner(ticket);

            _ticketsState[ticket].validator = validator;

            emit ApproveValidator(msg.sender, validator, ticket);
        }
    }

    function buyTickets(
        address to,
        uint[] memory tickets
    ) external payable internalTransfer {
        uint totalPrice;
        for (uint i; i < tickets.length; i++) {
            uint ticket = tickets[i];

            // give ticket to user
            _safeMint(to, ticket);

            uint price = getTicketPrice(ticket);
            totalPrice += price;

            // transfer fee to ticketchain
            i_escrow.deposit{
                value: _getPercentage(price, i_ticketchainConfig.feePercentage)
            }(i_ticketchainConfig.ticketchainAddress);

            emit Buy(msg.sender, to, ticket, price);
        }

        // check if user paid the correct amount
        if (msg.value != totalPrice) revert WrongValue(msg.value, totalPrice);
    }

    function giftTickets(
        address to,
        uint[] memory tickets
    ) external internalTransfer {
        for (uint i; i < tickets.length; i++) {
            uint ticket = tickets[i];

            // check if ticket is validated
            _checkTicketValidated(ticket);

            // transfer ticket to user
            safeTransferFrom(msg.sender, to, ticket);

            emit Gift(msg.sender, to, ticket);
        }
    }

    function refundTickets(uint[] memory tickets) external internalTransfer {
        if (
            block.timestamp >= _eventConfig.noRefund ||
            _eventConfig.refundPercentage.value == 0
        ) revert NoRefund();

        uint totalPrice;
        for (uint i; i < tickets.length; i++) {
            uint ticket = tickets[i];

            // check if ticket is validated
            _checkTicketValidated(ticket);

            // check if user is ticket owner
            _checkTicketOwner(ticket);

            // remove ticket from user
            _burn(ticket);

            // calculate refund (without fee)
            uint price = getTicketPrice(ticket);
            uint refundPrice = _getPercentage(
                price -
                    _getPercentage(price, i_ticketchainConfig.feePercentage),
                _eventConfig.refundPercentage
            );
            totalPrice += refundPrice;

            emit Refund(msg.sender, ticket, refundPrice);
        }

        // refund user in one transaction
        payable(msg.sender).sendValue(totalPrice);
    }

    /* ticket */

    function getTicketSupply() public view returns (uint) {
        uint totalSupply;
        for (uint i; i < i_packages.length; i++)
            totalSupply += i_packages[i].supply;
        return totalSupply;
    }

    function getTicketPackage(uint ticket) public view returns (uint) {
        uint totalSupply;
        for (uint i; i < i_packages.length; i++) {
            totalSupply += i_packages[i].supply;
            if (ticket < totalSupply) return i;
        }
        revert TicketDoesNotExist(ticket);
    }

    function getTicketPrice(uint ticket) public view returns (uint) {
        return i_packages[getTicketPackage(ticket)].price;
    }

    /* funds */

    function withdrawFunds() external {
        if (i_escrow.depositsOf(msg.sender) == 0) revert NothingToWithdraw();
        i_escrow.withdraw(payable(msg.sender));
    }

    function getFunds() external view returns (uint) {
        return i_escrow.depositsOf(msg.sender);
    }

    /* ticketchainConfig */

    function getTicketchainConfig()
        external
        view
        returns (Structs.TicketchainConfig memory)
    {
        return i_ticketchainConfig;
    }

    /* packages */

    function addPackages(Structs.Package[] memory packages) external onlyOwner {
        for (uint i; i < packages.length; i++) {
            i_packages.push(packages[i]);
        }
    }

    function getPackages() external view returns (Structs.Package[] memory) {
        return i_packages;
    }

    /* eventConfig */

    function setEventConfig(
        Structs.EventConfig memory eventConfig
    ) external onlyOwner {
        if (eventConfig.noRefund > eventConfig.end) revert InvalidInputs();

        _eventConfig = eventConfig;

        emit EventConfigChange(eventConfig);
    }

    function getEventConfig()
        external
        view
        returns (Structs.EventConfig memory)
    {
        return _eventConfig;
    }

    /* validators */

    function addValidators(address[] memory validators) external onlyOwner {
        for (uint i; i < validators.length; i++) {
            _validators.add(validators[i]);

            emit AddValidator(validators[i]);
        }
    }

    function removeValidators(address[] memory validators) external onlyOwner {
        for (uint i; i < validators.length; i++) {
            _validators.remove(validators[i]);

            emit RemoveValidator(validators[i]);
        }
    }

    function getValidators() external view returns (address[] memory) {
        return _validators.values();
    }

    function isValidator(address validator) external view returns (bool) {
        return _validators.contains(validator);
    }

    /* eventCanceled */

    function isEventCanceled() external view returns (bool) {
        return _eventCanceled;
    }

    /* ticketsState */

    function getTicketState(
        uint ticket
    ) external view returns (TicketState memory) {
        return _ticketsState[ticket];
    }

    /* internal */

    function _checkTicketOwner(uint ticket) internal view {
        if (msg.sender != ownerOf(ticket))
            revert UserNotTicketOwner(msg.sender, ticket);
    }

    function _checkTicketValidated(uint ticket) internal view {
        if (_ticketsState[ticket].validated)
            revert TicketAlreadyValidated(
                ticket,
                _ticketsState[ticket].validator
            );
    }

    function _getPercentage(
        uint value,
        Structs.Percentage memory percentage
    ) internal pure returns (uint) {
        return (value * percentage.value) / (100 * 10 ** percentage.decimals);
    }

    /* overrides */

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        if (_eventCanceled) revert EventCanceled();

        // revert if trying to transfer outside of contract when event is online
        if (block.timestamp < _eventConfig.end && !_internalTransfer)
            revert EventOnline();

        // revert if trying to transfer inside of contract when event is offline
        if (block.timestamp >= _eventConfig.end && _internalTransfer)
            revert EventOffline();

        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
