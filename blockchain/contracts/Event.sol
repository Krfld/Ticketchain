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

//todo trade tickets
//todo refund users if event is canceled

contract Event is Ownable, ERC721, ERC721Enumerable {
    using Address for address payable;
    using BitMaps for BitMaps.BitMap;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableMap for EnumerableMap.UintToUintMap;

    /* types */

    enum TicketStatus {
        NotApproved,
        Approved,
        Validated,
        ApprovedOrValidated
    }

    enum EventState {
        Closed,
        Open,
        CanRefund,
        CanCheckIn
    }

    /* variables */

    Escrow private immutable i_escrow;
    Structs.TicketchainConfig private _ticketchainConfig;
    Structs.EventConfig private _eventConfig;
    Structs.Package[] private _packages;
    EnumerableSet.AddressSet private _validators;

    bool private _transfersAllowed;
    bool private _eventCanceled;
    mapping(address => EnumerableMap.UintToUintMap) private _tickets;

    /* events */

    event Buy(
        address indexed user,
        address indexed to,
        uint indexed ticket,
        uint value
    );
    event Refund(address indexed user, uint indexed ticket, uint value);
    event Gift(address indexed user, address indexed to, uint indexed ticket);

    /* errors */

    error NoTickets();
    error NotValidator();
    error NothingToWithdraw();
    error InvalidInputs();
    error WrongEventState(EventState current, EventState expected);
    error EventCanceled();

    error TicketDoesNotExist(uint ticket);
    error UserNotTicketOwner(address user, uint ticket);
    error WrongTicketStatus(
        uint ticket,
        address validator,
        TicketStatus current,
        TicketStatus expected
    );

    error WrongValue(uint current, uint expected);

    /* functions */

    constructor(
        address owner,
        string memory name,
        string memory symbol,
        Structs.TicketchainConfig memory ticketchainConfig
    ) ERC721(name, symbol) {
        i_escrow = new Escrow();

        _ticketchainConfig = ticketchainConfig;

        transferOwnership(owner);
    }

    /* modifiers */

    modifier onlyValidators() {
        if (!_validators.contains(msg.sender)) revert NotValidator();
        _;
    }

    modifier checkEventState(EventState state) {
        if (_eventCanceled) revert EventCanceled();

        if (
            block.timestamp < _eventConfig.open ||
            block.timestamp >= _eventConfig.close
        ) {
            if (state != EventState.Closed)
                revert WrongEventState(EventState.Closed, state);
        } else if (state != EventState.Open && !_transfersAllowed) {
            if (
                block.timestamp < _eventConfig.refundDeadline &&
                state != EventState.CanRefund
            ) revert WrongEventState(EventState.CanRefund, state);

            if (
                block.timestamp >= _eventConfig.refundDeadline &&
                block.timestamp < _eventConfig.checkIn &&
                state != EventState.Open
            ) revert WrongEventState(EventState.Open, state);

            if (
                block.timestamp >= _eventConfig.checkIn &&
                state != EventState.CanCheckIn
            ) revert WrongEventState(EventState.CanCheckIn, state);
        }

        _;
    }

    modifier checkTickets(uint[] memory tickets) {
        if (tickets.length == 0) revert NoTickets();
        _;
    }

    modifier allowTransfers() {
        _transfersAllowed = true;
        _;
        _transfersAllowed = false;
    }

    /* owner */

    function withdraw() external onlyOwner checkEventState(EventState.Closed) {
        if (address(this).balance == 0) revert NothingToWithdraw();
        payable(owner()).sendValue(address(this).balance);
    }

    function cancel() external onlyOwner {
        //todo refund users (send to escrow for users and owner to claim)

        _eventCanceled = true;

        for (uint i = 0; i < totalSupply(); i++) {
            uint ticket = tokenByIndex(i);
            address user = ownerOf(ticket);

            // i_escrow.deposit{value: getTicketPrice(ticket)}(user); //todo
        }

        if (address(this).balance != 0)
            i_escrow.deposit{value: address(this).balance}(owner());
    }

    /* validator */

    function approveTickets(
        uint[] memory tickets
    )
        external
        onlyValidators
        checkEventState(EventState.CanCheckIn)
        checkTickets(tickets)
    {
        for (uint i = 0; i < tickets.length; i++) {
            if (_tickets[msg.sender].contains(tickets[i]))
                revert WrongTicketStatus(
                    tickets[i],
                    msg.sender,
                    TicketStatus.ApprovedOrValidated,
                    TicketStatus.NotApproved
                );

            _tickets[msg.sender].set(tickets[i], uint(TicketStatus.Approved));
        }
    }

    function verifyTickets(
        uint[] memory tickets
    )
        external
        view
        onlyValidators
        checkEventState(EventState.CanCheckIn)
        checkTickets(tickets)
        returns (bool)
    {
        for (uint i = 0; i < tickets.length; i++) {
            (, uint value) = _tickets[msg.sender].tryGet(tickets[i]);
            if (value == 0) return false;
        }
        return true;
    }

    /* user */

    function validateTickets(
        uint[] memory tickets,
        address validator
    ) external checkEventState(EventState.CanCheckIn) checkTickets(tickets) {
        for (uint i = 0; i < tickets.length; i++) {
            if (msg.sender != ownerOf(tickets[i]))
                revert UserNotTicketOwner(msg.sender, tickets[i]);

            if (!_tickets[validator].contains(tickets[i]))
                revert WrongTicketStatus(
                    tickets[i],
                    validator,
                    TicketStatus.NotApproved,
                    TicketStatus.Approved
                );

            if (
                _tickets[validator].get(tickets[i]) ==
                uint(TicketStatus.Validated)
            )
                revert WrongTicketStatus(
                    tickets[i],
                    validator,
                    TicketStatus.Validated,
                    TicketStatus.Approved
                );

            _tickets[validator].set(tickets[i], uint(TicketStatus.Validated));
        }
    }

    function buy(
        address to,
        uint[] memory tickets
    )
        external
        payable
        checkEventState(EventState.Open)
        checkTickets(tickets)
        allowTransfers
    {
        uint totalPrice;
        for (uint i = 0; i < tickets.length; i++) {
            _safeMint(to, tickets[i]);

            uint price = getTicketPrice(tickets[i]);
            totalPrice += price;

            i_escrow.deposit{
                value: getPercentage(price, _ticketchainConfig.feePercentage)
            }(_ticketchainConfig.ticketchainAddress);

            emit Buy(msg.sender, to, tickets[i], price);
        }
        if (msg.value != totalPrice) revert WrongValue(msg.value, totalPrice);
    }

    function refund(
        uint[] memory tickets
    )
        external
        checkEventState(EventState.CanRefund)
        checkTickets(tickets)
        allowTransfers
    {
        uint totalPrice;
        for (uint i = 0; i < tickets.length; i++) {
            if (msg.sender != ownerOf(tickets[i]))
                revert UserNotTicketOwner(msg.sender, tickets[i]);

            _burn(tickets[i]);

            uint price = getTicketPrice(tickets[i]);
            uint refundPrice = getPercentage(
                price - getPercentage(price, _ticketchainConfig.feePercentage),
                _eventConfig.refundPercentage
            );
            totalPrice += refundPrice;

            emit Refund(msg.sender, tickets[i], refundPrice);
        }

        payable(msg.sender).sendValue(totalPrice);
    }

    function gift(
        address to,
        uint[] memory tickets
    )
        external
        checkEventState(EventState.Open)
        checkTickets(tickets)
        allowTransfers
    {
        for (uint i = 0; i < tickets.length; i++) {
            safeTransferFrom(msg.sender, to, tickets[i]);

            emit Gift(msg.sender, to, tickets[i]);
        }
    }

    function claimFunds() external {
        if (i_escrow.depositsOf(msg.sender) == 0) revert NothingToWithdraw();
        i_escrow.withdraw(payable(msg.sender));
    }

    /* ticket */

    function getTicketPackage(uint ticket) public view returns (uint) {
        uint totalSupply;
        for (uint i = 0; i < _packages.length; i++) {
            totalSupply += _packages[i].supply;
            if (ticket < totalSupply) return i;
        }
        revert TicketDoesNotExist(ticket);
    }

    function getTicketPrice(uint ticket) public view returns (uint) {
        return _packages[getTicketPackage(ticket)].price;
    }

    /* ticketchainConfig */

    function getTicketchainConfig()
        external
        view
        returns (Structs.TicketchainConfig memory)
    {
        return _ticketchainConfig;
    }

    /* eventConfig */

    function setEventConfig(
        Structs.EventConfig memory eventConfig
    ) public onlyOwner {
        if (
            eventConfig.open >= eventConfig.close ||
            eventConfig.checkIn >= eventConfig.close ||
            eventConfig.checkIn < eventConfig.open ||
            eventConfig.refundDeadline >= eventConfig.close ||
            eventConfig.refundDeadline < eventConfig.open ||
            eventConfig.refundDeadline > eventConfig.checkIn
        ) revert InvalidInputs();

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

    function setPackages(
        Structs.Package[] memory packages
    ) public onlyOwner checkEventState(EventState.Closed) {
        _packages = packages;
    }

    function getPackages() external view returns (Structs.Package[] memory) {
        return _packages;
    }

    /* validators */

    function addValidators(address[] memory validators) public onlyOwner {
        for (uint i = 0; i < validators.length; i++) {
            _validators.add(validators[i]);
        }
    }

    function removeValidators(address[] memory validators) public onlyOwner {
        for (uint i = 0; i < validators.length; i++) {
            _validators.remove(validators[i]);
        }
    }

    function getValidators() external view returns (address[] memory) {
        return _validators.values();
    }

    /* overrides */

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    )
        internal
        override(ERC721, ERC721Enumerable)
        checkEventState(EventState.Closed)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /* pure */

    function getPercentage(
        uint value,
        Structs.Percentage memory percentage
    ) public pure returns (uint) {
        return (value * percentage.value) / (100 * 10 ** percentage.decimals);
    }
}
