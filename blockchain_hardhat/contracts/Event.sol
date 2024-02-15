// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./Structs.sol";

//todo nfts URIs

contract Event is Ownable, ERC721, ERC721Enumerable {
    using Strings for uint256;
    using Address for address payable;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    /* types */

    /* variables */

    Structs.TicketchainConfig private _ticketchainConfig;
    Structs.NFTConfig private _nftConfig;
    Structs.EventConfig private _eventConfig;
    Structs.Package[] private _packages;
    EnumerableSet.AddressSet private _admins;
    EnumerableSet.AddressSet private _validators;

    bool private _eventCanceled;
    bool private _internalTransfer;

    uint256 private _fees;
    EnumerableSet.UintSet private _ticketsValidated;

    /* events */

    event Buy(
        address indexed user,
        address indexed to,
        uint256 indexed ticket,
        uint256 value
    );
    event Gift(
        address indexed user,
        address indexed to,
        uint256 indexed ticket
    );
    event Refund(address indexed user, uint256 indexed ticket, uint256 value);
    event ValidateTicket(address indexed validator, uint256 indexed ticket);
    event CancelEvent();

    /* errors */

    error NoTickets();
    error NotTicketchain();
    error NotAdmin();
    error NotValidator(address user);
    error NothingToWithdraw();
    error InvalidInputs();

    error EventNotOnline();
    // error EventOnline();
    error EventNotOffline();
    error EventOffline();
    error NoRefund();
    error EventCanceled();

    error TicketDoesNotExist(uint256 ticket);
    error UserNotTicketOwner(address user, uint256 ticket);
    error TicketValidated(uint256 ticket);

    error WrongValue(uint256 current, uint256 expected);

    /* constructor */

    constructor(
        address owner,
        Structs.Percentage memory feePercentage,
        Structs.NFTConfig memory nftConfig
    ) Ownable(owner) ERC721(nftConfig.name, nftConfig.symbol) {
        _ticketchainConfig = Structs.TicketchainConfig(
            _msgSender(),
            feePercentage
        );
        _nftConfig = nftConfig;
    }

    /* modifiers */

    modifier onlyTicketchain() {
        if (_msgSender() != _ticketchainConfig.ticketchainAddress)
            revert NotTicketchain();
        _;
    }

    modifier onlyAdmins() {
        if (!_admins.contains(_msgSender()) && _msgSender() != owner())
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
        if (block.timestamp < _eventConfig.offlineDate)
            revert EventNotOffline();

        if (_fees == 0) revert NothingToWithdraw();
        uint256 fees = _fees;
        _fees = 0;
        payable(_ticketchainConfig.ticketchainAddress).sendValue(fees);
    }

    /* owner */

    function withdrawProfit() external onlyAdmins {
        if (block.timestamp < _eventConfig.offlineDate)
            revert EventNotOffline();

        uint256 profit = address(this).balance - _fees;
        if (profit == 0) revert NothingToWithdraw();
        payable(owner()).sendValue(profit);
    }

    function deployTickets(address to, Structs.Package[] memory packages)
        external
        onlyAdmins
    {
        for (uint256 i; i < packages.length; i++) {
            uint256 totalSupply = getTicketsSupply();

            for (uint256 j; j < packages[i].supply; j++)
                _safeMint(to, totalSupply + j);

            _packages.push(packages[i]);
        }
    }

    function cancelEvent() external onlyAdmins {
        _eventCanceled = true;

        emit CancelEvent();
    }

    /* validator */

    function validateTickets(uint256[] memory tickets)
        external
        checkValidator(_msgSender())
    {
        for (uint256 i; i < tickets.length; i++) {
            uint256 ticket = tickets[i];

            // check if ticket is validated
            _checkTicketValidated(ticket);

            _ticketsValidated.add(ticket);

            emit ValidateTicket(_msgSender(), ticket);
        }
    }

    /* user */

    function buyTickets(address to, uint256[] memory tickets)
        external
        payable
        internalTransfer
    {
        uint256 totalPrice;
        for (uint256 i; i < tickets.length; i++) {
            uint256 ticket = tickets[i];

            // give ticket to user
            _safeMint(to, ticket);

            // get ticket price
            uint256 price = getTicketPrice(ticket);
            totalPrice += price;

            // update fees
            _fees += _getPercentage(price, _ticketchainConfig.feePercentage);

            emit Buy(_msgSender(), to, ticket, price);
        }

        // check if user paid the correct amount
        if (msg.value != totalPrice) revert WrongValue(msg.value, totalPrice);
    }

    function giftTickets(address to, uint256[] memory tickets)
        external
        internalTransfer
    {
        for (uint256 i; i < tickets.length; i++) {
            uint256 ticket = tickets[i];

            // transfer ticket to user
            safeTransferFrom(_msgSender(), to, ticket);

            emit Gift(_msgSender(), to, ticket);
        }
    }

    function refundTickets(uint256[] memory tickets) external internalTransfer {
        if (
            (block.timestamp >= _eventConfig.noRefundDate ||
                _eventConfig.refundPercentage.value == 0) && !_eventCanceled
        ) revert NoRefund();

        uint256 totalPrice;
        for (uint256 i; i < tickets.length; i++) {
            uint256 ticket = tickets[i];

            // check if ticket is validated
            if(!_eventCanceled) _checkTicketValidated(ticket);

            // burn ticket from user
            _update(address(0), ticket, _msgSender());

            // calculate refund
            Structs.Percentage memory refundPercentage = !_eventCanceled
                ? _eventConfig.refundPercentage
                : Structs.Percentage(100, 0);

            uint256 refundPrice = _getPercentage(
                getTicketPrice(ticket),
                refundPercentage
            );
            totalPrice += refundPrice;

            // update fees
            _fees -= _getPercentage(
                refundPrice,
                _ticketchainConfig.feePercentage
            );

            emit Refund(_msgSender(), ticket, refundPrice);
        }

        // refund user in one transaction
        payable(_msgSender()).sendValue(totalPrice);
    }

    // --------------------------------------------------
    // --------------------------------------------------
    // --------------------------------------------------

    /* tickets */

    function getTicketsSupply() public view returns (uint256) {
        uint256 totalSupply;
        for (uint256 i; i < _packages.length; i++)
            totalSupply += _packages[i].supply;
        return totalSupply;
    }

    function getTicketPackageId(uint256 ticket) public view returns (uint256) {
        uint256 totalSupply;
        for (uint256 i; i < _packages.length; i++) {
            totalSupply += _packages[i].supply;
            if (ticket < totalSupply) return i;
        }
        revert TicketDoesNotExist(ticket);
    }

    function getTicketPrice(uint256 ticket) public view returns (uint256) {
        return _packages[getTicketPackageId(ticket)].price;
    }

    /* NFTs */

    function tokenURI(uint256 ticket)
        public
        view
        override
        returns (string memory)
    {
        uint256 packageId = getTicketPackageId(ticket);
        return
            string.concat(
                _baseURI(),
                packageId.toString(),
                "/",
                _packages[packageId].individualNfts ? ticket.toString() : "",
                ".json"
            );
    }

    function _baseURI() internal view override returns (string memory) {
        return _nftConfig.baseURI;
    }

    // --------------------------------------------------
    // --------------------------------------------------
    // --------------------------------------------------

    /* ticketchainConfig */

    function getTicketchainConfig()
        external
        view
        returns (Structs.TicketchainConfig memory)
    {
        return _ticketchainConfig;
    }

    /* packages */

    function addPackages(Structs.Package[] memory packages)
        external
        onlyAdmins
    {
        for (uint256 i; i < packages.length; i++) {
            _packages.push(packages[i]);
        }
    }

    function getPackages() external view returns (Structs.Package[] memory) {
        return _packages;
    }

    /* eventConfig */

    function setEventConfig(Structs.EventConfig memory eventConfig)
        external
        onlyAdmins
    {
        if (
            eventConfig.onlineDate > eventConfig.noRefundDate ||
            eventConfig.noRefundDate > eventConfig.offlineDate
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

    function addAdmins(address[] memory admins) external onlyAdmins {
        for (uint256 i; i < admins.length; i++) _admins.add(admins[i]);
    }

    function removeAdmins(address[] memory admins) external onlyAdmins {
        for (uint256 i; i < admins.length; i++) _admins.remove(admins[i]);
    }

    function getAdmins() external view returns (address[] memory) {
        return _admins.values();
    }

    /* validators */

    function addValidators(address[] memory validators) external onlyAdmins {
        for (uint256 i; i < validators.length; i++)
            _validators.add(validators[i]);
    }

    function removeValidators(address[] memory validators) external onlyAdmins {
        for (uint256 i; i < validators.length; i++)
            _validators.remove(validators[i]);
    }

    function getValidators() external view returns (address[] memory) {
        return _validators.values();
    }

    /* eventCanceled */

    function isEventCanceled() external view returns (bool) {
        return _eventCanceled;
    }

    /* internal */

    function _checkTicketOwner(uint256 ticket) internal view {
        if (_msgSender() != ownerOf(ticket))
            revert UserNotTicketOwner(_msgSender(), ticket);
    }

    function _checkTicketValidated(uint256 ticket) internal view {
        if (_ticketsValidated.contains(ticket)) revert TicketValidated(ticket);
    }

    function _getPercentage(uint256 value, Structs.Percentage memory percentage)
        internal
        pure
        returns (uint256)
    {
        return (value * percentage.value) / (100 * 10**percentage.decimals);
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
        // if (_eventCanceled) revert EventCanceled(); //! allow if refunding

        // revert if trying to transfer inside of contract when event has not started
        if (block.timestamp < _eventConfig.onlineDate && _internalTransfer)
            revert EventNotOnline();

        // revert if trying to transfer outside of contract when event has not ended
        if (block.timestamp < _eventConfig.offlineDate && !_internalTransfer)
            revert EventNotOffline();

        // revert if trying to transfer inside of contract when event has ended
        if (block.timestamp >= _eventConfig.offlineDate && _internalTransfer)
            revert EventOffline();

        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
