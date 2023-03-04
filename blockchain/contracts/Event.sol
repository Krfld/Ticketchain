// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

contract Event is Ownable, ERC721 {
    using BitMaps for BitMaps.BitMap;

    /* types */

    struct Package {
        uint price;
        uint supply;
    }

    struct EventConfig {
        uint eventEnd;
        uint refundDeadline;
        uint refundPercentage;
        uint decimals;
    }

    /* variables */

    Package[] private _packages;
    EventConfig private _eventConfig;

    bool private _transfersAllowed;

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
    error CallFailed();
    error EventNotEnded();
    error RefundDeadlineReached();
    error WrongValue(uint value, uint target);
    error TicketDoesNotExist(uint ticket);
    error NothingToWithdraw();

    // ----------------------------------------------------------------

    modifier checkTickets(uint[] memory tickets) {
        if (tickets.length == 0) revert NoTickets();
        _;
    }

    modifier allowTransfers() {
        _transfersAllowed = true;
        _;
        _transfersAllowed = false;
    }

    constructor(
        string memory name,
        string memory symbol
    )
        // EventConfig memory eventConfig
        ERC721(name, symbol)
    {
        // _eventConfig = eventConfig;
    }

    // ----------------------------------------------------------------

    function withdraw() external onlyOwner {
        if (block.timestamp < _eventConfig.eventEnd) revert EventNotEnded();
        if (address(this).balance == 0) revert NothingToWithdraw();
        (bool success, ) = tx.origin.call{value: address(this).balance}("");
        if (!success) revert CallFailed();
    }

    function buy(
        address to,
        uint[] memory tickets
    ) external payable checkTickets(tickets) allowTransfers {
        //? check if event ended

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
    ) external checkTickets(tickets) allowTransfers {
        if (block.timestamp >= _eventConfig.refundDeadline)
            revert RefundDeadlineReached();

        uint totalPrice;
        for (uint i = 0; i < tickets.length; i++) {
            require(
                _isApprovedOrOwner(_msgSender(), tickets[i]),
                "ERC721: caller is not token owner or approved"
            );
            _burn(tickets[i]);

            uint price = ticketPrice(tickets[i]);
            //todo refund a percentage defined by seller
            totalPrice += price;

            emit Refund(msg.sender, tickets[i], price);
        }

        (bool success, ) = msg.sender.call{value: totalPrice}("");
        if (!success) revert CallFailed();
    }

    function gift(
        address to,
        uint[] memory tickets
    ) external checkTickets(tickets) allowTransfers {
        for (uint i = 0; i < tickets.length; i++) {
            safeTransferFrom(msg.sender, to, tickets[i]);

            emit Gift(msg.sender, to, tickets[i]);
        }
    }

    /* ticket */

    function ticketPackage(uint ticket) public view returns (uint) {
        uint totalSupply;
        for (uint i = 0; i < _packages.length; i++) {
            totalSupply += _packages[i].supply;
            if (ticket < totalSupply) {
                return i;
            }
        }
        revert TicketDoesNotExist(ticket);
    }

    function ticketPrice(uint ticket) public view returns (uint) {
        return _packages[ticketPackage(ticket)].price;
    }

    /* getters */

    /* setters */

    /* overrides */

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override {
        if (block.timestamp < _eventConfig.eventEnd && !_transfersAllowed)
            revert EventNotEnded();

        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
