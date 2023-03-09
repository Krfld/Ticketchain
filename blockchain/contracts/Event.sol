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

//todo fees logic
//todo trade tickets
//todo refund users if event is canceled

contract Event is Ownable, ERC721, ERC721Enumerable {
    using Address for address payable;
    using BitMaps for BitMaps.BitMap;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableMap for EnumerableMap.UintToUintMap;

    /* types */

    enum TicketStatus {
        Approved,
        Validated
    }

    /* variables */

    Structs.TicketchainConfig private _ticketchainConfig;
    Escrow private immutable i_escrow;

    Structs.Package[] private _packages;
    Structs.EventConfig private _eventConfig;
    EnumerableSet.AddressSet private _validators;

    bool private _transfersAllowed;
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
    error EventEnded();
    error EventNotEnded();
    error RefundDeadlineReached();

    error TicketDoesNotExist(uint ticket);
    error UserNotTicketOwner(address user, uint ticket);
    error TicketAlreadyApproved(uint ticket, address validator);
    error TicketNotApproved(uint ticket, address validator);
    error TicketAlreadyValidated(uint ticket);

    error WrongValue(uint value, uint target);

    /* functions */

    constructor(
        address owner,
        string memory name,
        string memory symbol,
        Structs.TicketchainConfig memory ticketchainConfig,
        Structs.EventConfig memory eventConfig,
        address[] memory validators //todo add setter and getter
    ) ERC721(name, symbol) {
        transferOwnership(owner);
        i_escrow = new Escrow();

        _ticketchainConfig = ticketchainConfig;
        setEventConfig(eventConfig);

        for (uint i = 0; i < validators.length; i++)
            _validators.add(validators[i]); //todo change to setter
    }

    /* modifiers */

    modifier onlyValidators() {
        if (!_validators.contains(msg.sender)) revert NotValidator();
        _;
    }

    modifier checkEventEnded() {
        if (block.timestamp >= _eventConfig.eventEnd) revert EventEnded();
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

    function withdraw() external onlyOwner {
        if (block.timestamp < _eventConfig.eventEnd) revert EventNotEnded();
        if (address(this).balance == 0) revert NothingToWithdraw();
        payable(owner()).sendValue(address(this).balance);
    }

    function cancel() external onlyOwner {
        //todo refund users (send to escrow for users and owner to claim)
        // if (address(this).balance != 0)
        //     payable(owner()).sendValue(address(this).balance);
    }

    /* validator */

    function approveTickets(
        uint[] memory tickets
    ) external onlyValidators checkEventEnded checkTickets(tickets) {
        for (uint i = 0; i < tickets.length; i++) {
            if (_tickets[msg.sender].contains(tickets[i]))
                revert TicketAlreadyApproved(tickets[i], msg.sender);

            _tickets[msg.sender].set(tickets[i], uint(TicketStatus.Approved));
        }
    }

    function verifyTickets(
        uint[] memory tickets
    )
        external
        view
        onlyValidators
        checkEventEnded
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
    ) external checkEventEnded checkTickets(tickets) {
        for (uint i = 0; i < tickets.length; i++) {
            if (msg.sender != ownerOf(tickets[i]))
                revert UserNotTicketOwner(msg.sender, tickets[i]);

            if (!_tickets[validator].contains(tickets[i]))
                revert TicketNotApproved(tickets[i], validator);

            if (
                _tickets[validator].get(tickets[i]) ==
                uint(TicketStatus.Validated)
            ) revert TicketAlreadyValidated(tickets[i]);

            _tickets[validator].set(tickets[i], uint(TicketStatus.Validated));
        }
    }

    function buy(
        address to,
        uint[] memory tickets
    ) external payable checkEventEnded checkTickets(tickets) allowTransfers {
        uint totalPrice;
        for (uint i = 0; i < tickets.length; i++) {
            _safeMint(to, tickets[i]);

            uint price = ticketPrice(tickets[i]);
            totalPrice += price;

            emit Buy(msg.sender, to, tickets[i], price);
        }
        if (msg.value != totalPrice) revert WrongValue(msg.value, totalPrice);
    }

    function refund(
        uint[] memory tickets
    ) external checkEventEnded checkTickets(tickets) allowTransfers {
        if (block.timestamp >= _eventConfig.refundDeadline)
            revert RefundDeadlineReached();

        uint totalPrice;
        for (uint i = 0; i < tickets.length; i++) {
            if (msg.sender != ownerOf(tickets[i]))
                revert UserNotTicketOwner(msg.sender, tickets[i]);

            _burn(tickets[i]);

            uint price = getPercentage(
                ticketPrice(tickets[i]),
                _eventConfig.refundPercentage
            );
            totalPrice += price;

            emit Refund(msg.sender, tickets[i], price);
        }

        payable(msg.sender).sendValue(totalPrice);
    }

    function gift(
        address to,
        uint[] memory tickets
    ) external checkEventEnded checkTickets(tickets) allowTransfers {
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

    function ticketPackage(uint ticket) public view returns (uint) {
        uint totalSupply;
        for (uint i = 0; i < _packages.length; i++) {
            totalSupply += _packages[i].supply;
            if (ticket < totalSupply) return i;
        }
        revert TicketDoesNotExist(ticket);
    }

    function ticketPrice(uint ticket) public view returns (uint) {
        return _packages[ticketPackage(ticket)].price;
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
        //todo check inputs
        if (eventConfig.refundDeadline > eventConfig.eventEnd)
            revert InvalidInputs();

        _eventConfig = eventConfig;
    }

    function getEventConfig()
        external
        view
        returns (Structs.EventConfig memory)
    {
        return _eventConfig;
    }

    /* overrides */

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        if (!_transfersAllowed && block.timestamp < _eventConfig.eventEnd)
            revert EventNotEnded();

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
