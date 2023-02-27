// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";

contract Ticketchain {
    struct TicketsConfig {
        uint supply;
        uint price;
        mapping(address => uint[]) balances;
    }

    mapping(uint => TicketsConfig) private _tickets;

    constructor() {}
}
