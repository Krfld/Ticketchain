// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

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

    event EventRegistered(
        address indexed organizer,
        address indexed eventAddress
    );

    /* errors */

    error NotOrganizer();
    error NoEvent();

    /* modifiers */

    modifier onlyOrganizers() {
        if (!_organizers.contains(msg.sender)) revert NotOrganizer();
        _;
    }

    /* owner */

    function withdrawFees(address eventAddress) external onlyOwner {
        if (!_events.contains(eventAddress)) revert NoEvent();

        Event(eventAddress).withdrawFees();

        payable(owner()).sendValue(address(this).balance);
    }

    /* organizers */

    function registerEvent(
        Structs.ERC721Config memory erc721Config
    ) external onlyOrganizers {
        address eventAddress = address(
            new Event(msg.sender, _feePercentage, erc721Config) //, packages)
        );
        _events.add(eventAddress);

        emit EventRegistered(msg.sender, eventAddress);
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

    function removeEvent(address eventAddress) external onlyOwner {
        _events.remove(eventAddress);
    }

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
