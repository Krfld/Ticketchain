// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./Event.sol";
import "./Structs.sol";

contract Ticketchain is Ownable {
    using Address for address payable;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _events;
    Structs.Percentage private _feePercentage;

    /* functions */

    function registerEvent(
        address owner,
        string memory name,
        string memory symbol
    ) external onlyOwner {
        _events.add(
            address(
                new Event(
                    name,
                    symbol,
                    owner,
                    Structs.TicketchainConfig(address(this), _feePercentage)
                )
            )
        );
    }

    function withdrawFees() external onlyOwner {
        for (uint i = 0; i < _events.length(); i++)
            if (Event(_events.at(i)).getFunds() != 0)
                Event(_events.at(i)).withdrawFunds();
    }

    /* events */

    function getEvents() external view returns (address[] memory) {
        return _events.values();
    }

    /* feePercentage */

    function setFeePercentage(
        Structs.Percentage memory feePercentage
    ) external onlyOwner {
        _feePercentage = feePercentage;
    }

    function getFeePercentage()
        external
        view
        returns (Structs.Percentage memory)
    {
        return _feePercentage;
    }
}
