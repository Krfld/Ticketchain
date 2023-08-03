// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

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
        uint startDate;
        uint endDate;
        uint noRefundDate;
        Percentage refundPercentage;
    }

    struct ERC721Config {
        string name;
        string symbol;
    }
}
