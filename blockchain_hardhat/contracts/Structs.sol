// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
        uint onlineDate;
        uint offlineDate;
        uint noRefundDate;
        Percentage refundPercentage;
    }

    struct Package {
        uint id;
        uint price;
        uint supply;
    }

    struct NFTConfig {
        string name;
        string symbol;
    }
}
