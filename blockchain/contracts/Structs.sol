// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library Structs {
    struct Percentage {
        uint value;
        uint decimals;
    }

    struct TicketchainConfig {
        address ticketchain;
        Percentage feePercentage;
    }

    struct EventConfig {
        //todo add eventStart
        uint eventEnd;
        uint refundDeadline;
        Percentage refundPercentage;
    }

    struct Package {
        uint price;
        uint supply;
    }
}
