// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/escrow/Escrow.sol";

import "./Structs.sol";

//todo maybe figure out a way to allow organizers to change packages without ticket id conflicts
//todo allow organizers to deploy special tickets
//todo nfts URIs
//todo event name and description

contract Event is Ownable, ERC721, ERC721Enumerable {
    using Address for address payable;
    using BitMaps for BitMaps.BitMap;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableMap for EnumerableMap.UintToUintMap;

    /* types */

    enum EventState {
        NotStarted,
        Started,
        Ended,
        CanRefund,
        NoRefund
    }

    struct TicketStatus {
        bool validated;
        address validator;
    }

    /* variables */

    Escrow private immutable i_escrow;
    Structs.TicketchainConfig private _ticketchainConfig;
    Structs.EventConfig private _eventConfig;
    Structs.Package[] private _packages;
    EnumerableSet.AddressSet private _validators;

    bool private _transfersAllowed;
    bool private _eventCanceled;
    mapping(uint => TicketStatus) private _ticketsStatus;

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
        Structs.Percentage memory feePercentage
    ) ERC721(ERC721Config.name, ERC721Config.symbol) {
        i_escrow = new Escrow();

        _ticketchainConfig = Structs.TicketchainConfig(
            msg.sender,
            feePercentage
        );

        transferOwnership(owner);
    }

    /* modifiers */

    modifier onlyValidators() {
        if (!_validators.contains(msg.sender)) revert NotValidator(msg.sender);
        _;
    }

    modifier checkEventState(EventState state) {
        if (_eventCanceled) revert EventCanceled();

        // if (
        //     block.timestamp < _eventConfig.open ||
        //     block.timestamp >= _eventConfig.close
        // ) {
        //     if (state != EventState.Closed)
        //         revert WrongEventState(EventState.Closed, state);
        // } else if (state != EventState.Open && !_transfersAllowed) {
        //     if (
        //         block.timestamp < _eventConfig.noRefund &&
        //         state != EventState.CanRefund
        //     ) revert WrongEventState(EventState.CanRefund, state);

        //     if (
        //         block.timestamp >= _eventConfig.noRefund &&
        //         state != EventState.NoRefund
        //     ) revert WrongEventState(EventState.NoRefund, state);
        // }

        _;
    }

    // modifier checkTickets(uint[] memory tickets) {
    //     if (tickets.length == 0) revert NoTickets();
    //     _;
    // }

    modifier allowTransfers() {
        _transfersAllowed = true;
        _;
        _transfersAllowed = false;
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

    function withdrawProfit()
        external
        onlyOwner
        checkEventState(EventState.NoRefund)
    {
        // if (address(this).balance == 0) revert NothingToWithdraw();
        payable(owner()).sendValue(address(this).balance);
    }

    //! probably won't work for LOTS of users
    function cancel() external onlyOwner {
        _eventCanceled = true;

        for (uint i = 0; i < totalSupply(); i++) {
            uint ticket = tokenByIndex(i);
            address user = ownerOf(ticket);

            //? _burn(tokenByIndex(i));

            uint price = getTicketPrice(ticket);
            i_escrow.deposit{
                value: price -
                    getPercentage(price, _ticketchainConfig.feePercentage)
            }(user);
        }

        if (address(this).balance != 0)
            i_escrow.deposit{value: address(this).balance}(owner());
    }

    /* validator */

    function validateTickets(
        uint[] memory tickets
    )
        external
        onlyValidators // checkTickets(tickets)
    {
        for (uint i = 0; i < tickets.length; i++) {
            if (_ticketsStatus[tickets[i]].validated)
                revert TicketAlreadyValidated(
                    tickets[i],
                    _ticketsStatus[tickets[i]].validator
                );

            if (_ticketsStatus[tickets[i]].validator != msg.sender)
                revert ValidatorNotApproved(msg.sender, tickets[i]);

            _ticketsStatus[tickets[i]].validated = true;

            //todo emit event
        }
    }

    /* user */

    function approveTickets(
        uint[] memory tickets,
        address validator // checkTickets(tickets)
    ) external {
        for (uint i = 0; i < tickets.length; i++) {
            if (msg.sender != ownerOf(tickets[i]))
                revert UserNotTicketOwner(msg.sender, tickets[i]);

            if (_ticketsStatus[tickets[i]].validated)
                revert TicketAlreadyValidated(
                    tickets[i],
                    _ticketsStatus[tickets[i]].validator
                );

            _ticketsStatus[tickets[i]].validator = validator;

            //todo emit event
        }
    }

    function buy(
        address to,
        uint[] memory tickets
    )
        external
        payable
        checkEventState(EventState.Started)
        // checkTickets(tickets)
        allowTransfers
    {
        uint totalPrice;
        for (uint i = 0; i < tickets.length; i++) {
            // give ticket to user
            _safeMint(to, tickets[i]);

            uint price = getTicketPrice(tickets[i]);
            totalPrice += price;

            // transfer fee to ticketchain
            i_escrow.deposit{
                value: getPercentage(price, _ticketchainConfig.feePercentage)
            }(_ticketchainConfig.ticketchainAddress);

            emit Buy(msg.sender, to, tickets[i], price);
        }
        if (msg.value != totalPrice) revert WrongValue(msg.value, totalPrice);
    }

    function gift(
        address to,
        uint[] memory tickets
    )
        external
        checkEventState(EventState.Started)
        // checkTickets(tickets)
        allowTransfers
    {
        for (uint i = 0; i < tickets.length; i++) {
            // transfer ticket to user
            safeTransferFrom(msg.sender, to, tickets[i]);

            emit Gift(msg.sender, to, tickets[i]);
        }
    }

    function refund(
        uint[] memory tickets
    )
        external
        checkEventState(EventState.CanRefund)
        // checkTickets(tickets)
        allowTransfers
    {
        uint totalPrice;
        for (uint i = 0; i < tickets.length; i++) {
            if (msg.sender != ownerOf(tickets[i]))
                revert UserNotTicketOwner(msg.sender, tickets[i]);

            // remove ticket from user
            _burn(tickets[i]);

            // calculate refund (without fee)
            uint price = getTicketPrice(tickets[i]);
            uint refundPrice = getPercentage(
                price - getPercentage(price, _ticketchainConfig.feePercentage),
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

    function setPackages(
        Structs.Package[] memory packages
    ) external onlyOwner checkEventState(EventState.NotStarted) {
        _packages = packages;
    }

    function getPackages() external view returns (Structs.Package[] memory) {
        return _packages;
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

    function getPercentage(
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
    )
        internal
        override(ERC721, ERC721Enumerable)
        checkEventState(EventState.Ended)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
