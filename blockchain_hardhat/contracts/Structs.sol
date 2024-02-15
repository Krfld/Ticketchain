// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

library Structs {
    struct Percentage {
        uint256 value;
        uint256 decimals;
    }

    struct TicketchainConfig {
        address ticketchainAddress;
        Percentage feePercentage;
    }

    struct EventConfig {
        uint256 onlineDate;
        uint256 offlineDate;
        uint256 noRefundDate;
        Percentage refundPercentage;
    }

    struct Package {
        uint256 price;
        uint256 supply;
        bool individualNfts;
    }

    struct NFTConfig {
        string name;
        string symbol;
        string baseURI;
    }
}
