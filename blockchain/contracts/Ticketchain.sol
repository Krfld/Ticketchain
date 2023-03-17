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

    /* variables */

    Structs.Percentage private _feePercentage;

    EnumerableSet.AddressSet private _organizers;
    EnumerableSet.AddressSet private _events;

    /* events */

    /* errors */

    error NotOrganizer();

    /* modifiers */

    modifier onlyOrganizers() {
        if (!_organizers.contains(msg.sender)) revert NotOrganizer();
        _;
    }

    /* owner */

    //todo change to withdraw directly
    function withdrawFees() external onlyOwner {
        for (uint i = 0; i < _events.length(); i++)
            if (Event(_events.at(i)).getFunds() != 0)
                Event(_events.at(i)).withdrawFunds();
    }

    /* organizers */

    function registerEvent(
        string memory name,
        string memory symbol
    ) external onlyOrganizers {
        _events.add(
            address(new Event(msg.sender, name, symbol, _feePercentage))
        );
    }

    /* organizers */

    function addOrganizer(address organizer) external onlyOwner {
        _organizers.add(organizer);
    }

    function removeOrganizer(address organizer) external onlyOwner {
        _organizers.remove(organizer);
    }

    function getOrganizers() external view returns (address[] memory) {
        return _organizers.values();
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
