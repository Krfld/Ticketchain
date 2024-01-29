// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./Structs.sol";

//todo nfts URIs

contract Event is Ownable, ERC721, ERC721Enumerable {
    using Address for address payable;
    using EnumerableSet for EnumerableSet.AddressSet;

    /* types */

    struct TicketState {
        bool validated;
        address validator;
    }

    /* variables */

    Structs.TicketchainConfig private _ticketchainConfig;
    Structs.Package[] private _packages;
    Structs.EventConfig private _eventConfig;
    EnumerableSet.AddressSet private _admins;
    EnumerableSet.AddressSet private _validators;

    uint private _fees;
    bool private _eventCanceled;
    bool private _internalTransfer;
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

    /* errors */

    error NoTickets();
    error NotTicketchain();
    error NotAdmin();
    error NotValidator(address user);
    error NothingToWithdraw();
    error InvalidInputs();

    error EventNotAvailable();
    // error EventAvailable();
    error EventNotEnded();
    error EventEnded();
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
        Structs.Percentage memory feePercentage,
        Structs.NFTConfig memory nftConfig
    ) Ownable(owner) ERC721(nftConfig.name, nftConfig.symbol) {
        _ticketchainConfig = Structs.TicketchainConfig(
            msg.sender,
            feePercentage
        );
    }

    /* modifiers */

    modifier onlyTicketchain() {
        if (msg.sender != _ticketchainConfig.ticketchainAddress)
            revert NotTicketchain();
        _;
    }

    modifier onlyAdminsOrOwner() {
        if (!_admins.contains(msg.sender) && msg.sender != owner())
            revert NotAdmin();
        _;
    }

    modifier checkValidator(address validator) {
        if (!_validators.contains(validator)) revert NotValidator(validator);
        _;
    }

    modifier internalTransfer() {
        _internalTransfer = true;
        _;
        _internalTransfer = false;
    }

    /* ticketchain */

    function withdrawFees() external onlyTicketchain {
        if (block.timestamp < _eventConfig.endDate) revert EventNotEnded();

        if (_fees == 0) revert NothingToWithdraw();
        uint fees = _fees;
        _fees = 0;
        payable(_ticketchainConfig.ticketchainAddress).sendValue(fees);
    }

    /* owner */

    function withdrawProfit() external onlyAdminsOrOwner {
        if (block.timestamp < _eventConfig.endDate) revert EventNotEnded();

        uint profit = address(this).balance - _fees;
        if (profit == 0) revert NothingToWithdraw();
        payable(owner()).sendValue(profit);
    }

    function deployTickets(
        address to,
        Structs.Package[] memory packages
    ) external onlyAdminsOrOwner {
        for (uint i; i < packages.length; i++) {
            uint totalSupply = getTicketSupply();

            for (uint j; j < packages[i].supply; j++)
                _safeMint(to, totalSupply + j);

            _packages.push(packages[i]);
        }
    }

    function cancelEvent() external onlyAdminsOrOwner {
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

            // get ticket price
            uint price = getTicketPrice(ticket);
            totalPrice += price;

            // update fees
            _fees += _getPercentage(price, _ticketchainConfig.feePercentage);

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
            (block.timestamp >= _eventConfig.noRefundDate ||
                _eventConfig.refundPercentage.value == 0) && !_eventCanceled
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

            // calculate refund
            Structs.Percentage memory refundPercentage = !_eventCanceled
                ? _eventConfig.refundPercentage
                : Structs.Percentage(100, 0);

            uint refundPrice = _getPercentage(
                getTicketPrice(ticket),
                refundPercentage
            );
            totalPrice += refundPrice;

            // update fees
            _fees -= _getPercentage(
                refundPrice,
                _ticketchainConfig.feePercentage
            );

            emit Refund(msg.sender, ticket, refundPrice);
        }

        // refund user in one transaction
        payable(msg.sender).sendValue(totalPrice);
    }

    // --------------------------------------------------
    // --------------------------------------------------
    // --------------------------------------------------

    /* ticket */

    function getTicketSupply() public view returns (uint) {
        uint totalSupply;
        for (uint i; i < _packages.length; i++)
            totalSupply += _packages[i].supply;
        return totalSupply;
    }

    function getTicketPackage(uint ticket) public view returns (uint) {
        uint totalSupply;
        for (uint i; i < _packages.length; i++) {
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

    /* packages */

    function addPackages(
        Structs.Package[] memory packages
    ) external onlyAdminsOrOwner {
        for (uint i; i < packages.length; i++) {
            _packages.push(packages[i]);
        }
    }

    function getPackages() external view returns (Structs.Package[] memory) {
        return _packages;
    }

    /* eventConfig */

    function setEventConfig(
        Structs.EventConfig memory eventConfig
    ) external onlyAdminsOrOwner {
        if (
            eventConfig.availableDate > eventConfig.noRefundDate ||
            eventConfig.noRefundDate > eventConfig.endDate
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

    /* admins */

    function addAdmins(address[] memory admins) external onlyAdminsOrOwner {
        for (uint i; i < admins.length; i++) _admins.add(admins[i]);
    }

    function removeAdmins(address[] memory admins) external onlyAdminsOrOwner {
        for (uint i; i < admins.length; i++) _admins.remove(admins[i]);
    }

    function getAdmins() external view returns (address[] memory) {
        return _admins.values();
    }

    /* validators */

    function addValidators(
        address[] memory validators
    ) external onlyAdminsOrOwner {
        for (uint i; i < validators.length; i++) _validators.add(validators[i]);
    }

    function removeValidators(
        address[] memory validators
    ) external onlyAdminsOrOwner {
        for (uint i; i < validators.length; i++)
            _validators.remove(validators[i]);
    }

    function getValidators() external view returns (address[] memory) {
        return _validators.values();
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

    // --------------------------------------------------
    // --------------------------------------------------
    // --------------------------------------------------

    /* overrides */

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        if (_eventCanceled) revert EventCanceled();

        // revert if trying to transfer outside of contract when event has not ended
        if (block.timestamp < _eventConfig.endDate && !_internalTransfer)
            revert EventNotEnded();

        // revert if trying to transfer inside of contract when event has not started
        if (block.timestamp < _eventConfig.availableDate && _internalTransfer)
            revert EventNotAvailable();

        // revert if trying to transfer inside of contract when event has ended
        if (block.timestamp >= _eventConfig.endDate && _internalTransfer)
            revert EventEnded();

        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
