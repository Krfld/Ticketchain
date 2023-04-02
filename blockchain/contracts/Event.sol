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

//? maybe figure out a way to allow organizers to change packages without ticket id conflicts
//todo allow organizers to deploy special tickets
//todo nfts URIs
//todo event info (name, description, ...)

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
    Structs.EventConfig private _eventConfig;
    Structs.Package[] private i_packages;
    EnumerableSet.AddressSet private _validators;

    bool private _internalTransfer;
    bool private _eventCanceled;
    mapping(uint => TicketState) private _ticketsState;

    /* events */

    //todo add more events
    event Buy(
        address indexed user,
        address indexed to,
        uint indexed ticket,
        uint value
    );
    event Gift(address indexed user, address indexed to, uint indexed ticket);
    event Refund(address indexed user, uint indexed ticket, uint value);

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
    error TicketValidated(uint ticket, address validator);

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

    modifier onlyValidators() {
        if (!_validators.contains(msg.sender)) revert NotValidator(msg.sender);
        _;
    }

    modifier internalTransfer() {
        _internalTransfer = true;
        _;
        _internalTransfer = false;
    }

    /* functions */

    function withdrawFunds() external {
        // if (i_escrow.depositsOf(msg.sender) == 0) revert NothingToWithdraw();
        i_escrow.withdraw(payable(msg.sender));
    }

    function getFunds() external view returns (uint) {
        return i_escrow.depositsOf(msg.sender);
    }

    /* owner */

    function withdrawProfit() external onlyOwner {
        if (block.timestamp < _eventConfig.end)
            revert WrongEventState(EventState.Online, EventState.Offline);

        // if (address(this).balance == 0) revert NothingToWithdraw();
        payable(owner()).sendValue(address(this).balance);
    }

    //! probably won't work for LOTS of users
    function cancelEvent() external onlyOwner {
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
    }

    /* validator */

    function validateTickets(uint[] memory tickets) external onlyValidators {
        for (uint i = 0; i < tickets.length; i++) {
            if (_ticketsState[tickets[i]].validator != msg.sender)
                revert ValidatorNotApproved(msg.sender, tickets[i]);

            _checkTicketValidated(tickets[i]);

            _ticketsState[tickets[i]].validated = true;

            //todo emit event
        }
    }

    /* user */

    function approveTickets(uint[] memory tickets, address validator) external {
        for (uint i = 0; i < tickets.length; i++) {
            // check if user is ticket owner
            _checkTicketOwner(tickets[i]);

            // check if ticket is validated
            _checkTicketValidated(tickets[i]);

            _ticketsState[tickets[i]].validator = validator;

            //todo emit event
        }
    }

    function buy(
        address to,
        uint[] memory tickets
    ) external payable internalTransfer {
        uint totalPrice;
        for (uint i = 0; i < tickets.length; i++) {
            // give ticket to user
            _safeMint(to, tickets[i]);

            uint price = getTicketPrice(tickets[i]);
            totalPrice += price;

            // transfer fee to ticketchain
            i_escrow.deposit{
                value: _getPercentage(price, i_ticketchainConfig.feePercentage)
            }(i_ticketchainConfig.ticketchainAddress);

            emit Buy(msg.sender, to, tickets[i], price);
        }

        // check if user paid the correct price
        if (msg.value != totalPrice) revert WrongValue(msg.value, totalPrice);
    }

    function gift(address to, uint[] memory tickets) external internalTransfer {
        for (uint i = 0; i < tickets.length; i++) {
            // check if ticket is validated
            _checkTicketValidated(tickets[i]);

            // transfer ticket to user
            safeTransferFrom(msg.sender, to, tickets[i]);

            emit Gift(msg.sender, to, tickets[i]);
        }
    }

    function refund(uint[] memory tickets) external internalTransfer {
        if (
            block.timestamp >= _eventConfig.noRefund ||
            _eventConfig.refundPercentage.value == 0
        ) revert NoRefund();

        uint totalPrice;
        for (uint i = 0; i < tickets.length; i++) {
            // check if user is ticket owner
            _checkTicketOwner(tickets[i]);

            // check if ticket is validated
            _checkTicketValidated(tickets[i]);

            // remove ticket from user
            _burn(tickets[i]);

            // calculate refund (without fee)
            uint price = getTicketPrice(tickets[i]);
            uint refundPrice = _getPercentage(
                price -
                    _getPercentage(price, i_ticketchainConfig.feePercentage),
                _eventConfig.refundPercentage
            );
            totalPrice += refundPrice;

            emit Refund(msg.sender, tickets[i], refundPrice);
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

    /* eventConfig */

    function setEventConfig(
        Structs.EventConfig memory eventConfig
    ) external onlyOwner {
        if (eventConfig.noRefund > eventConfig.end) revert InvalidInputs();
        _eventConfig = eventConfig;
    }

    function getEventConfig()
        external
        view
        returns (Structs.EventConfig memory)
    {
        return _eventConfig;
    }

    /* packages */

    // function setPackages(
    //     Structs.Package[] memory packages
    // ) external onlyOwner {
    //     _packages = packages;
    // }

    function getPackages() external view returns (Structs.Package[] memory) {
        return i_packages;
    }

    /* validators */

    function addValidators(address[] memory validators) external onlyOwner {
        for (uint i = 0; i < validators.length; i++) {
            _validators.add(validators[i]);
        }
    }

    function removeValidators(address[] memory validators) external onlyOwner {
        for (uint i = 0; i < validators.length; i++) {
            _validators.remove(validators[i]);
        }
    }

    function getValidators() external view returns (address[] memory) {
        return _validators.values();
    }

    /* internal */

    function _checkTicketOwner(uint ticket) internal view {
        if (msg.sender != ownerOf(ticket))
            revert UserNotTicketOwner(msg.sender, ticket);
    }

    function _checkTicketValidated(uint ticket) internal view {
        if (_ticketsState[ticket].validated)
            revert TicketValidated(ticket, _ticketsState[ticket].validator);
    }

    function _getPercentage(
        uint value,
        Structs.Percentage memory percentage
    ) internal pure returns (uint) {
        return (value * percentage.value) / (100 * 10 ** percentage.decimals);
    }

    /* overrides */

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

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
