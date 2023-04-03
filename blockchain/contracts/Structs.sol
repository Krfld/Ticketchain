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

    struct Package {
        uint id;
        uint price;
        uint supply;
    }

    struct EventConfig {
        uint end;
        uint noRefund;
        Percentage refundPercentage;
    }

    struct ERC721Config {
        string name;
        string symbol;
    }
}
