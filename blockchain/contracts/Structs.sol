// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library Structs {
    struct Percentage {
        uint value;
        uint decimals;
    }

    struct TicketchainConfig {
        address ticketchainAddress;
        Percentage feePercentage;
    }

    struct EventConfig {
        uint start;
        uint refundDeadline;
        uint checkIn;
        uint end;
        Percentage refundPercentage;
    }

    struct Package {
        uint id;
        uint price;
        uint supply;
    }
}
