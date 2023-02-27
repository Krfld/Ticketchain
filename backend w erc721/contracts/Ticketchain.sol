// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// contract Ticketchain {
//     Tickets private _tickets = new Tickets(1, 10, "x0", "x0");

//     function buy(uint256 id) public payable {
//         _tickets.buy(msg.sender, id);
//     }
// }

contract Tickets is Ownable, ERC721 {
    /* types */

    /* variables */

    // struct Range {
    //     uint start;
    //     uint end;
    // }

    // struct Package {
    //     uint price;
    //     Range[] tickets;
    // }

    // mapping(uint => Package) private packages;

    ///

    uint[] private _packagesPrice;
    uint[] private _packagesSupply;

    /* events */

    /* errors */

    error WrongValue(uint value);
    error TicketDoesNotExist(uint ticket);

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {}

    // ----------------------------------------------------------------

    function buy(address to, uint[] memory tickets) public payable {
        // require(msg.value == ticketPrice(tickets[i]), "Wrong price"); // check price
        //todo limit tickets
        for (uint i = 0; i < tickets.length; i++) {
            //todo change supply logic for packages
            _safeMint(to, tickets[i]);
        }
        //todo emit event
    }

    function refund(uint[] memory tickets) public {
        //todo refund a percentage defined by seller
        //todo verify refund deadline
        for (uint i = 0; i < tickets.length; i++) {
            require(
                _isApprovedOrOwner(_msgSender(), tickets[i]),
                "ERC721: caller is not token owner or approved"
            );
            _burn(tickets[i]);
        }
        // (bool success, ) = msg.sender.call{value: i_price * tickets.length}("");
        //todo check success
        // if (!success) revert CallFailedError();
        //todo emit event
    }

    function gift(address to, uint[] memory tickets) public {
        for (uint i = 0; i < tickets.length; i++) {
            safeTransferFrom(msg.sender, to, tickets[i]);
        }
        //todo emit event
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);

        //todo logic to avoid trades on marketplaces
    }

    /* setters */

    function setPackages(
        uint[] memory prices,
        uint[] memory supply
    ) public onlyOwner {
        require(prices.length == supply.length, "Wrong length");
        _packagesPrice = prices;
        _packagesSupply = supply;
    }

    /* package */

    // function getPackage(
    //     uint tier
    // ) public view returns (uint price, uint supply) {
    //     return (_packagesPrice[tier], _packagesSupply[tier]);
    // }

    // function setPackage(uint tier, uint price, uint supply) public onlyOwner {
    //     _packagesPrice[tier] = price;
    //     _packagesSupply[tier] = supply;
    // }

    /* view */

    function ticketPackage(uint ticket) public view returns (uint) {
        uint totalSupply;
        for (uint i = 0; i < _packagesSupply.length; i++) {
            totalSupply += _packagesSupply[i];
            if (ticket < totalSupply) {
                return i;
            }
        }
        revert TicketDoesNotExist(ticket);
    }

    function ticketPrice(uint ticket) public view returns (uint) {
        return _packagesPrice[ticketPackage(ticket)];
    }
}
