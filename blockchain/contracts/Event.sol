// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/escrow/Escrow.sol";

import "./Structs.sol";

//todo assign validators to packages
//todo allow organizers to deploy special tickets
//todo nfts URIs

contract Event is Ownable, ERC721, ERC721Enumerable {
    using Address for address payable;
    using BitMaps for BitMaps.BitMap;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableMap for EnumerableMap.UintToUintMap;

    /* types */

    enum EventState {
        Online,
        NoRefund,
        Offline
    }

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

    error WrongEventState(EventState current, EventState expected);
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
        Structs.ERC721Config memory ERC721Config,
        Structs.Percentage memory feePercentage,
        Structs.Package[] memory packages
    ) ERC721(ERC721Config.name, ERC721Config.symbol) {
        i_escrow = new Escrow();

        i_ticketchainConfig = Structs.TicketchainConfig(
            msg.sender,
            feePercentage
        );

        i_packages = packages;

        transferOwnership(owner);
    }

    /* modifiers */

    modifier checkValidator(address validator) {
        if (!isValidator(validator)) revert NotValidator(validator);
        _;
    }

    modifier internalTransfer() {
        _internalTransfer = true;
        _;
        _internalTransfer = false;
    }

    /* functions */

    function withdrawFunds() external {
        if (i_escrow.depositsOf(msg.sender) == 0) revert NothingToWithdraw();
        i_escrow.withdraw(payable(msg.sender));
    }

    function getFunds() external view returns (uint) {
        return i_escrow.depositsOf(msg.sender);
    }

    /* owner */

    function withdrawProfit() external onlyOwner {
        if (block.timestamp < _eventConfig.end)
            revert WrongEventState(EventState.Online, EventState.Offline);

        if (address(this).balance == 0) revert NothingToWithdraw();

        payable(owner()).sendValue(address(this).balance);
    }

    //! probably won't work for LOTS of users
    function cancelEvent() external onlyOwner internalTransfer {
        for (uint i = 0; i < totalSupply(); i++) {
            uint ticket = tokenByIndex(i);
            address user = ownerOf(ticket);

            //? _burn(tokenByIndex(i));

            uint price = getTicketPrice(ticket);
            i_escrow.deposit{
                value: price -
                    _getPercentage(price, i_ticketchainConfig.feePercentage)
            }(user);
        }

        if (address(this).balance != 0)
            i_escrow.deposit{value: address(this).balance}(owner());

        // cancel only after burn transfer
        _eventCanceled = true;

        emit CancelEvent();
    }

    /* validator */

    function validateTickets(
        uint[] memory tickets
    ) external checkValidator(msg.sender) {
        for (uint i = 0; i < tickets.length; i++) {
            uint ticket = tickets[i];

            if (_ticketsState[ticket].validator != msg.sender)
                revert ValidatorNotApproved(msg.sender, ticket);

            // check if ticket is validated
            _checkTicketValidated(ticket);

            _ticketsState[ticket].validated = true;

            emit ValidateTicket(msg.sender, ticket);
        }
    }

    /* user */

    function approveTickets(
        uint[] memory tickets,
        address validator
    ) external checkValidator(validator) {
        for (uint i = 0; i < tickets.length; i++) {
            uint ticket = tickets[i];

            // check if user is ticket owner
            _checkTicketOwner(ticket);

            // check if ticket is validated
            _checkTicketValidated(ticket);

            _ticketsState[ticket].validator = validator;

            emit ApproveValidator(msg.sender, validator, ticket);
        }
    }

    function buy(
        address to,
        uint[] memory tickets
    ) external payable internalTransfer {
        uint totalPrice;
        for (uint i = 0; i < tickets.length; i++) {
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

        // check if user paid the correct price
        if (msg.value != totalPrice) revert WrongValue(msg.value, totalPrice);
    }

    function gift(address to, uint[] memory tickets) external internalTransfer {
        for (uint i = 0; i < tickets.length; i++) {
            uint ticket = tickets[i];

            // check if ticket is validated
            _checkTicketValidated(ticket);

            // transfer ticket to user
            safeTransferFrom(msg.sender, to, ticket);

            emit Gift(msg.sender, to, ticket);
        }
    }

    function refund(uint[] memory tickets) external internalTransfer {
        if (
            block.timestamp >= _eventConfig.noRefund ||
            _eventConfig.refundPercentage.value == 0
        ) revert NoRefund();

        uint totalPrice;
        for (uint i = 0; i < tickets.length; i++) {
            uint ticket = tickets[i];

            // check if user is ticket owner
            _checkTicketOwner(ticket);

            // check if ticket is validated
            _checkTicketValidated(ticket);

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

    function getTicketPackage(uint ticket) public view returns (uint) {
        uint totalSupply;
        for (uint i = 0; i < i_packages.length; i++) {
            totalSupply += i_packages[i].supply;
            if (ticket < totalSupply) return i;
        }
        revert TicketDoesNotExist(ticket);
    }

    function getTicketPrice(uint ticket) public view returns (uint) {
        return i_packages[getTicketPackage(ticket)].price;
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
        for (uint i = 0; i < validators.length; i++) {
            _validators.add(validators[i]);

            emit AddValidator(validators[i]);
        }
    }

    function removeValidators(address[] memory validators) external onlyOwner {
        for (uint i = 0; i < validators.length; i++) {
            _validators.remove(validators[i]);

            emit RemoveValidator(validators[i]);
        }
    }

    function getValidators() external view returns (address[] memory) {
        return _validators.values();
    }

    function isValidator(address validator) public view returns (bool) {
        return _validators.contains(validator);
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

        if (block.timestamp < _eventConfig.end && !_internalTransfer)
            revert WrongEventState(EventState.Online, EventState.Offline);

        if (block.timestamp >= _eventConfig.end && _internalTransfer)
            revert WrongEventState(EventState.Offline, EventState.Online);

        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
