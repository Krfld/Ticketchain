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
        string name;
        string description;
        string image;
        string website;
        string location;
        uint start;
        uint refundDeadline;
        uint checkIn;
        uint end;
        Percentage refundPercentage;
    }

    struct Package {
        uint id;
        string name;
        string description;
        string image;
        uint price;
        uint supply;
    }

    struct ERC721Config {
        string name;
        string symbol;
    }
}
