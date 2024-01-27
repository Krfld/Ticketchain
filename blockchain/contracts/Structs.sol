// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

library Structs {
    struct Percentage {
        uint value;
        uint decimals;
    }

    struct TicketchainConfig {
        address ticketchainAddress;
        Percentage feePercentage;
    }

    struct Package {
        uint id;
        uint price;
        uint supply;
    }

    struct EventConfig {
        uint availableDate;
        uint endDate;
        uint noRefundDate;
        Percentage refundPercentage;
    }

    struct NFTConfig {
        string name;
        string symbol;
    }
}
