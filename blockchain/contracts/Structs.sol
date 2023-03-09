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
        uint open;
        uint refundDeadline;
        uint checkIn;
        uint close;
        Percentage refundPercentage;
    }

    struct Package {
        uint price;
        uint supply;
    }
}
