import 'dart:convert';

import 'package:get/get.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

enum TicketchainFunctions {
  /// write
  // addOrganizer,
  // registerEvent,
  // removeEvent,
  // removeOrganizer,
  // setFeePercentage,
  // withdrawFees,

  /// read
  getEvents,
  // getFeePercentage,
  // getOrganizers,
}

enum EventFunctions {
  /// write
  // addAdmins,
  // addPackages,
  // addValidators,
  buyTickets,
  // cancelEvent,
  // deployTickets,
  giftTickets,
  refundTickets,
  // removeAdmins,
  // removeValidators,
  // setEventConfig,
  //? validateTickets,
  // withdrawFees,
  // withdrawProfit,

  /// read
  getAdmins,
  getEventConfig,
  getPackages,
  getTicketchainConfig,
  getTicketPackageId,
  getTicketPrice,
  getTicketsSupply,
  getValidators,
  isEventCanceled,
  name,
  symbol,
  tokenURI,
}

class TicketchainService extends GetxService {
  static TicketchainService get to =>
      Get.isRegistered() ? Get.find() : Get.put(TicketchainService._());
  TicketchainService._();

  static DeployedContract _ticketchainContract() => DeployedContract(
        ContractAbi.fromJson(_ticketchainAbi, 'Ticketchain'),
        EthereumAddress.fromHex(_address),
      );

  static DeployedContract _eventContract(String address) => DeployedContract(
        ContractAbi.fromJson(_eventAbi, 'Event'),
        EthereumAddress.fromHex(address),
      );

  static const String _address = '0x7Bd1965330537cc2708b32D05E56d8BC7C04E17a';
  static final String _ticketchainAbi = jsonEncode(
    [
      {
        "inputs": [
          {"internalType": "address", "name": "account", "type": "address"}
        ],
        "name": "AddressInsufficientBalance",
        "type": "error"
      },
      {"inputs": [], "name": "FailedInnerCall", "type": "error"},
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
              {"internalType": "string", "name": "symbol", "type": "string"}
            ],
            "internalType": "struct Structs.NFTConfig",
            "name": "nftConfig",
            "type": "tuple"
          }
        ],
        "name": "registerEvent",
        "outputs": [],
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
    ],
  );
  static final String _eventAbi = jsonEncode(
    [
      {
        "inputs": [
          {"internalType": "address", "name": "owner", "type": "address"},
          {
            "components": [
              {"internalType": "uint256", "name": "value", "type": "uint256"},
              {"internalType": "uint256", "name": "decimals", "type": "uint256"}
            ],
            "internalType": "struct Structs.Percentage",
            "name": "feePercentage",
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
        "stateMutability": "nonpayable",
        "type": "constructor"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "account", "type": "address"}
        ],
        "name": "AddressInsufficientBalance",
        "type": "error"
      },
      {
        "inputs": [],
        "name": "ERC721EnumerableForbiddenBatchMint",
        "type": "error"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "sender", "type": "address"},
          {"internalType": "uint256", "name": "tokenId", "type": "uint256"},
          {"internalType": "address", "name": "owner", "type": "address"}
        ],
        "name": "ERC721IncorrectOwner",
        "type": "error"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "operator", "type": "address"},
          {"internalType": "uint256", "name": "tokenId", "type": "uint256"}
        ],
        "name": "ERC721InsufficientApproval",
        "type": "error"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "approver", "type": "address"}
        ],
        "name": "ERC721InvalidApprover",
        "type": "error"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "operator", "type": "address"}
        ],
        "name": "ERC721InvalidOperator",
        "type": "error"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "owner", "type": "address"}
        ],
        "name": "ERC721InvalidOwner",
        "type": "error"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "receiver", "type": "address"}
        ],
        "name": "ERC721InvalidReceiver",
        "type": "error"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "sender", "type": "address"}
        ],
        "name": "ERC721InvalidSender",
        "type": "error"
      },
      {
        "inputs": [
          {"internalType": "uint256", "name": "tokenId", "type": "uint256"}
        ],
        "name": "ERC721NonexistentToken",
        "type": "error"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "owner", "type": "address"},
          {"internalType": "uint256", "name": "index", "type": "uint256"}
        ],
        "name": "ERC721OutOfBoundsIndex",
        "type": "error"
      },
      {"inputs": [], "name": "EventCanceled", "type": "error"},
      {"inputs": [], "name": "EventNotOffline", "type": "error"},
      {"inputs": [], "name": "EventNotOnline", "type": "error"},
      {"inputs": [], "name": "EventOffline", "type": "error"},
      {"inputs": [], "name": "FailedInnerCall", "type": "error"},
      {"inputs": [], "name": "InvalidInputs", "type": "error"},
      {"inputs": [], "name": "NoRefund", "type": "error"},
      {"inputs": [], "name": "NoTickets", "type": "error"},
      {"inputs": [], "name": "NotAdmin", "type": "error"},
      {"inputs": [], "name": "NotTicketchain", "type": "error"},
      {
        "inputs": [
          {"internalType": "address", "name": "user", "type": "address"}
        ],
        "name": "NotValidator",
        "type": "error"
      },
      {"inputs": [], "name": "NothingToWithdraw", "type": "error"},
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
        "inputs": [
          {"internalType": "uint256", "name": "ticket", "type": "uint256"}
        ],
        "name": "TicketDoesNotExist",
        "type": "error"
      },
      {
        "inputs": [
          {"internalType": "uint256", "name": "ticket", "type": "uint256"}
        ],
        "name": "TicketValidated",
        "type": "error"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "user", "type": "address"},
          {"internalType": "uint256", "name": "ticket", "type": "uint256"}
        ],
        "name": "UserNotTicketOwner",
        "type": "error"
      },
      {
        "inputs": [
          {"internalType": "uint256", "name": "current", "type": "uint256"},
          {"internalType": "uint256", "name": "expected", "type": "uint256"}
        ],
        "name": "WrongValue",
        "type": "error"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "address",
            "name": "owner",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "approved",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "uint256",
            "name": "tokenId",
            "type": "uint256"
          }
        ],
        "name": "Approval",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "address",
            "name": "owner",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "operator",
            "type": "address"
          },
          {
            "indexed": false,
            "internalType": "bool",
            "name": "approved",
            "type": "bool"
          }
        ],
        "name": "ApprovalForAll",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "address",
            "name": "user",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "to",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "uint256",
            "name": "ticket",
            "type": "uint256"
          },
          {
            "indexed": false,
            "internalType": "uint256",
            "name": "value",
            "type": "uint256"
          }
        ],
        "name": "Buy",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [],
        "name": "CancelEvent",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "address",
            "name": "user",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "to",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "uint256",
            "name": "ticket",
            "type": "uint256"
          }
        ],
        "name": "Gift",
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
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "address",
            "name": "user",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "uint256",
            "name": "ticket",
            "type": "uint256"
          },
          {
            "indexed": false,
            "internalType": "uint256",
            "name": "value",
            "type": "uint256"
          }
        ],
        "name": "Refund",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "address",
            "name": "from",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "to",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "uint256",
            "name": "tokenId",
            "type": "uint256"
          }
        ],
        "name": "Transfer",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "address",
            "name": "validator",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "uint256",
            "name": "ticket",
            "type": "uint256"
          }
        ],
        "name": "ValidateTicket",
        "type": "event"
      },
      {
        "inputs": [
          {"internalType": "address[]", "name": "admins", "type": "address[]"}
        ],
        "name": "addAdmins",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "components": [
              {"internalType": "uint256", "name": "id", "type": "uint256"},
              {"internalType": "uint256", "name": "price", "type": "uint256"},
              {"internalType": "uint256", "name": "supply", "type": "uint256"},
              {"internalType": "bool", "name": "individualNfts", "type": "bool"}
            ],
            "internalType": "struct Structs.Package[]",
            "name": "packages",
            "type": "tuple[]"
          }
        ],
        "name": "addPackages",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address[]",
            "name": "validators",
            "type": "address[]"
          }
        ],
        "name": "addValidators",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "to", "type": "address"},
          {"internalType": "uint256", "name": "tokenId", "type": "uint256"}
        ],
        "name": "approve",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "owner", "type": "address"}
        ],
        "name": "balanceOf",
        "outputs": [
          {"internalType": "uint256", "name": "", "type": "uint256"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "to", "type": "address"},
          {"internalType": "uint256[]", "name": "tickets", "type": "uint256[]"}
        ],
        "name": "buyTickets",
        "outputs": [],
        "stateMutability": "payable",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "cancelEvent",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "to", "type": "address"},
          {
            "components": [
              {"internalType": "uint256", "name": "id", "type": "uint256"},
              {"internalType": "uint256", "name": "price", "type": "uint256"},
              {"internalType": "uint256", "name": "supply", "type": "uint256"},
              {"internalType": "bool", "name": "individualNfts", "type": "bool"}
            ],
            "internalType": "struct Structs.Package[]",
            "name": "packages",
            "type": "tuple[]"
          }
        ],
        "name": "deployTickets",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "getAdmins",
        "outputs": [
          {"internalType": "address[]", "name": "", "type": "address[]"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "uint256", "name": "tokenId", "type": "uint256"}
        ],
        "name": "getApproved",
        "outputs": [
          {"internalType": "address", "name": "", "type": "address"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "getEventConfig",
        "outputs": [
          {
            "components": [
              {
                "internalType": "uint256",
                "name": "onlineDate",
                "type": "uint256"
              },
              {
                "internalType": "uint256",
                "name": "offlineDate",
                "type": "uint256"
              },
              {
                "internalType": "uint256",
                "name": "noRefundDate",
                "type": "uint256"
              },
              {
                "components": [
                  {
                    "internalType": "uint256",
                    "name": "value",
                    "type": "uint256"
                  },
                  {
                    "internalType": "uint256",
                    "name": "decimals",
                    "type": "uint256"
                  }
                ],
                "internalType": "struct Structs.Percentage",
                "name": "refundPercentage",
                "type": "tuple"
              }
            ],
            "internalType": "struct Structs.EventConfig",
            "name": "",
            "type": "tuple"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "getPackages",
        "outputs": [
          {
            "components": [
              {"internalType": "uint256", "name": "id", "type": "uint256"},
              {"internalType": "uint256", "name": "price", "type": "uint256"},
              {"internalType": "uint256", "name": "supply", "type": "uint256"},
              {"internalType": "bool", "name": "individualNfts", "type": "bool"}
            ],
            "internalType": "struct Structs.Package[]",
            "name": "",
            "type": "tuple[]"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "uint256", "name": "ticket", "type": "uint256"}
        ],
        "name": "getTicketPackageId",
        "outputs": [
          {"internalType": "uint256", "name": "", "type": "uint256"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "uint256", "name": "ticket", "type": "uint256"}
        ],
        "name": "getTicketPrice",
        "outputs": [
          {"internalType": "uint256", "name": "", "type": "uint256"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "getTicketchainConfig",
        "outputs": [
          {
            "components": [
              {
                "internalType": "address",
                "name": "ticketchainAddress",
                "type": "address"
              },
              {
                "components": [
                  {
                    "internalType": "uint256",
                    "name": "value",
                    "type": "uint256"
                  },
                  {
                    "internalType": "uint256",
                    "name": "decimals",
                    "type": "uint256"
                  }
                ],
                "internalType": "struct Structs.Percentage",
                "name": "feePercentage",
                "type": "tuple"
              }
            ],
            "internalType": "struct Structs.TicketchainConfig",
            "name": "",
            "type": "tuple"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "getTicketsSupply",
        "outputs": [
          {"internalType": "uint256", "name": "", "type": "uint256"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "getValidators",
        "outputs": [
          {"internalType": "address[]", "name": "", "type": "address[]"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "to", "type": "address"},
          {"internalType": "uint256[]", "name": "tickets", "type": "uint256[]"}
        ],
        "name": "giftTickets",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "owner", "type": "address"},
          {"internalType": "address", "name": "operator", "type": "address"}
        ],
        "name": "isApprovedForAll",
        "outputs": [
          {"internalType": "bool", "name": "", "type": "bool"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "isEventCanceled",
        "outputs": [
          {"internalType": "bool", "name": "", "type": "bool"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "name",
        "outputs": [
          {"internalType": "string", "name": "", "type": "string"}
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
          {"internalType": "uint256", "name": "tokenId", "type": "uint256"}
        ],
        "name": "ownerOf",
        "outputs": [
          {"internalType": "address", "name": "", "type": "address"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "uint256[]", "name": "tickets", "type": "uint256[]"}
        ],
        "name": "refundTickets",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "address[]", "name": "admins", "type": "address[]"}
        ],
        "name": "removeAdmins",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "internalType": "address[]",
            "name": "validators",
            "type": "address[]"
          }
        ],
        "name": "removeValidators",
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
          {"internalType": "address", "name": "from", "type": "address"},
          {"internalType": "address", "name": "to", "type": "address"},
          {"internalType": "uint256", "name": "tokenId", "type": "uint256"}
        ],
        "name": "safeTransferFrom",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "from", "type": "address"},
          {"internalType": "address", "name": "to", "type": "address"},
          {"internalType": "uint256", "name": "tokenId", "type": "uint256"},
          {"internalType": "bytes", "name": "data", "type": "bytes"}
        ],
        "name": "safeTransferFrom",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "operator", "type": "address"},
          {"internalType": "bool", "name": "approved", "type": "bool"}
        ],
        "name": "setApprovalForAll",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {
            "components": [
              {
                "internalType": "uint256",
                "name": "onlineDate",
                "type": "uint256"
              },
              {
                "internalType": "uint256",
                "name": "offlineDate",
                "type": "uint256"
              },
              {
                "internalType": "uint256",
                "name": "noRefundDate",
                "type": "uint256"
              },
              {
                "components": [
                  {
                    "internalType": "uint256",
                    "name": "value",
                    "type": "uint256"
                  },
                  {
                    "internalType": "uint256",
                    "name": "decimals",
                    "type": "uint256"
                  }
                ],
                "internalType": "struct Structs.Percentage",
                "name": "refundPercentage",
                "type": "tuple"
              }
            ],
            "internalType": "struct Structs.EventConfig",
            "name": "eventConfig",
            "type": "tuple"
          }
        ],
        "name": "setEventConfig",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "bytes4", "name": "interfaceId", "type": "bytes4"}
        ],
        "name": "supportsInterface",
        "outputs": [
          {"internalType": "bool", "name": "", "type": "bool"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "symbol",
        "outputs": [
          {"internalType": "string", "name": "", "type": "string"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "uint256", "name": "index", "type": "uint256"}
        ],
        "name": "tokenByIndex",
        "outputs": [
          {"internalType": "uint256", "name": "", "type": "uint256"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "owner", "type": "address"},
          {"internalType": "uint256", "name": "index", "type": "uint256"}
        ],
        "name": "tokenOfOwnerByIndex",
        "outputs": [
          {"internalType": "uint256", "name": "", "type": "uint256"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "uint256", "name": "ticket", "type": "uint256"}
        ],
        "name": "tokenURI",
        "outputs": [
          {"internalType": "string", "name": "", "type": "string"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "totalSupply",
        "outputs": [
          {"internalType": "uint256", "name": "", "type": "uint256"}
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          {"internalType": "address", "name": "from", "type": "address"},
          {"internalType": "address", "name": "to", "type": "address"},
          {"internalType": "uint256", "name": "tokenId", "type": "uint256"}
        ],
        "name": "transferFrom",
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
          {"internalType": "uint256[]", "name": "tickets", "type": "uint256[]"}
        ],
        "name": "validateTickets",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "withdrawFees",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "withdrawProfit",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      }
    ],
  );
}
