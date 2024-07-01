import 'dart:convert';

String ticketchainAbi = jsonEncode([
  {"inputs": [], "name": "FailedCall", "type": "error"},
  {
    "inputs": [
      {"internalType": "uint256", "name": "balance", "type": "uint256"},
      {"internalType": "uint256", "name": "needed", "type": "uint256"}
    ],
    "name": "InsufficientBalance",
    "type": "error"
  },
  {"inputs": [], "name": "NoEvent", "type": "error"},
  {"inputs": [], "name": "NotOrganizer", "type": "error"},
  {
    "inputs": [
      {"internalType": "address", "name": "owner", "type": "address"}
    ],
    "name": "OwnableInvalidOwner",
    "type": "error"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "account", "type": "address"}
    ],
    "name": "OwnableUnauthorizedAccount",
    "type": "error"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "organizer",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "eventAddress",
        "type": "address"
      }
    ],
    "name": "EventRegistered",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "previousOwner",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "OwnershipTransferred",
    "type": "event"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "organizer", "type": "address"}
    ],
    "name": "addOrganizer",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getEvents",
    "outputs": [
      {"internalType": "address[]", "name": "", "type": "address[]"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getFeePercentage",
    "outputs": [
      {
        "components": [
          {"internalType": "uint256", "name": "value", "type": "uint256"},
          {"internalType": "uint256", "name": "decimals", "type": "uint256"}
        ],
        "internalType": "struct Structs.Percentage",
        "name": "",
        "type": "tuple"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "getOrganizers",
    "outputs": [
      {"internalType": "address[]", "name": "", "type": "address[]"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "owner",
    "outputs": [
      {"internalType": "address", "name": "", "type": "address"}
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "components": [
          {"internalType": "string", "name": "name", "type": "string"},
          {"internalType": "string", "name": "description", "type": "string"},
          {"internalType": "string", "name": "location", "type": "string"},
          {"internalType": "uint256", "name": "date", "type": "uint256"},
          {"internalType": "uint256", "name": "offlineDate", "type": "uint256"},
          {
            "internalType": "uint256",
            "name": "noRefundDate",
            "type": "uint256"
          },
          {
            "components": [
              {"internalType": "uint256", "name": "value", "type": "uint256"},
              {"internalType": "uint256", "name": "decimals", "type": "uint256"}
            ],
            "internalType": "struct Structs.Percentage",
            "name": "refundPercentage",
            "type": "tuple"
          }
        ],
        "internalType": "struct Structs.EventConfig",
        "name": "eventConfig",
        "type": "tuple"
      },
      {
        "components": [
          {"internalType": "string", "name": "name", "type": "string"},
          {"internalType": "string", "name": "symbol", "type": "string"},
          {"internalType": "string", "name": "baseURI", "type": "string"}
        ],
        "internalType": "struct Structs.NFTConfig",
        "name": "nftConfig",
        "type": "tuple"
      }
    ],
    "name": "registerEvent",
    "outputs": [
      {"internalType": "address", "name": "", "type": "address"}
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "eventAddress", "type": "address"}
    ],
    "name": "removeEvent",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "organizer", "type": "address"}
    ],
    "name": "removeOrganizer",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "renounceOwnership",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "components": [
          {"internalType": "uint256", "name": "value", "type": "uint256"},
          {"internalType": "uint256", "name": "decimals", "type": "uint256"}
        ],
        "internalType": "struct Structs.Percentage",
        "name": "feePercentage",
        "type": "tuple"
      }
    ],
    "name": "setFeePercentage",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "newOwner", "type": "address"}
    ],
    "name": "transferOwnership",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "eventAddress", "type": "address"}
    ],
    "name": "withdrawFees",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]);
