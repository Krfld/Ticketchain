import 'dart:developer';

import 'package:get/get.dart';
import 'package:ticketchain/constants/event_abi.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/models/event_config.dart';
import 'package:ticketchain/models/nft_config.dart';
import 'package:ticketchain/models/package.dart';
import 'package:ticketchain/models/package_config.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/services/wc_service.dart';
import 'package:ticketchain/services/web3_service.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

enum EventFunctions {
  /// write
  buyTickets,
  giftTickets,
  refundTickets,
  validateTickets,

  /// read
  balanceOf,
  getEventConfig,
  getNFTConfig,
  getPackageConfigs,
  getPackageTicketsBought,
  getTicketPackageConfig,
  getTicketsValidated,
  getValidators,
  isEventCanceled,
  tokenURI,
}

class EventService extends GetxService {
  static EventService get to =>
      Get.isRegistered() ? Get.find() : Get.put(EventService._());
  EventService._();

  DeployedContract _eventContract(String eventAddress) => DeployedContract(
        ContractAbi.fromJson(eventAbi, 'Event'),
        EthereumAddress.fromHex(eventAddress),
      );

  Future<EventModel> getEvent(String eventAddress) async {
    List<PackageConfig> packageConfigs = await getPackageConfigs(eventAddress);
    List<PackageModel> packages = [];
    for (int i = 0; i < packageConfigs.length; i++) {
      List<int> ticketsBought = await getPackageTicketsBought(eventAddress, i)
        ..sort();
      packages.add(PackageModel(
        packageConfigs[i],
        ticketsBought,
      ));
    }
    EventModel event = EventModel(
      eventAddress,
      await getEventConfig(eventAddress),
      packages,
      await getNFTConfig(eventAddress),
      await EventService.to.getTicketsValidated(eventAddress),
      await isEventCanceled(eventAddress),
    );
    return event;
  }

  Future<Ticket> getTicket(String eventAddress, int ticketId) async {
    return Ticket(
      ticketId,
      await getEvent(eventAddress),
      await getTicketPackageConfig(eventAddress, ticketId),
    );
  }

  Transaction getValidateTicketsTransaction(
    String eventAddress,
    List<int> tickets,
    String ownerAddress,
    Credentials validator,
  ) {
    return Transaction.callContract(
      contract: _eventContract(eventAddress),
      function: _eventContract(eventAddress)
          .function(EventFunctions.validateTickets.name),
      parameters: [
        tickets.map((e) => BigInt.from(e)).toList(),
        EthereumAddress.fromHex(ownerAddress),
      ],
      from: validator.address,
    );
  }

  // ----------------------------------------------------------------------------------------------------
  // Write ----------------------------------------------------------------------------------------------
  // ----------------------------------------------------------------------------------------------------

  Future<bool> buyTickets(
      String eventAddress, List<int> tickets, EtherAmount price) async {
    try {
      String txHash = await WCService.to.write(
        _eventContract(eventAddress),
        EventFunctions.buyTickets.name,
        parameters: [
          EthereumAddress.fromHex(WCService.to.address),
          tickets.map((e) => BigInt.from(e)).toList(),
        ],
        value: price,
        // EtherAmount.inWei(tickets.fold(
        //   BigInt.zero,
        //   (previousValue, element) =>
        //       previousValue + element.package.price.getInWei,
        // )),
      );
      return await Web3Service.to.waitForTx(txHash);
    } catch (e) {
      log('catch buyTickets: $e');
      return false;
    }
  }

  Future<bool> giftTickets(
      String eventAddress, String address, List<Ticket> tickets) async {
    try {
      String txHash = await WCService.to.write(
        _eventContract(eventAddress),
        EventFunctions.giftTickets.name,
        parameters: [
          EthereumAddress.fromHex(address),
          tickets.map((e) => BigInt.from(e.id)).toList(),
        ],
      );
      return await Web3Service.to.waitForTx(txHash);
    } catch (e) {
      log('catch giftTickets: $e');
      return false;
    }
  }

  Future<bool> refundTickets(String eventAddress, List<Ticket> tickets) async {
    try {
      String txHash = await WCService.to.write(
        _eventContract(eventAddress),
        EventFunctions.refundTickets.name,
        parameters: [
          tickets.map((e) => BigInt.from(e.id)).toList(),
        ],
      );
      return await Web3Service.to.waitForTx(txHash);
    } catch (e) {
      log('catch refundTickets: $e');
      return false;
    }
  }

  // ----------------------------------------------------------------------------------------------------
  // Read -----------------------------------------------------------------------------------------------
  // ----------------------------------------------------------------------------------------------------

  Future<int> balanceOf(String eventAddress, String address) async {
    BigInt balance = await WCService.to.read(
      _eventContract(eventAddress),
      EventFunctions.balanceOf.name,
      [EthereumAddress.fromHex(address)],
    );
    // print('balance $balance');
    return balance.toInt();
  }

  Future<EventConfig> getEventConfig(String eventAddress) async {
    List eventConfig = await WCService.to.read(
      _eventContract(eventAddress),
      EventFunctions.getEventConfig.name,
    );
    // print('eventConfig $eventConfig');
    return EventConfig.fromTuple(eventConfig);
  }

  Future<NFTConfig> getNFTConfig(String eventAddress) async {
    List nftConfig = await WCService.to.read(
      _eventContract(eventAddress),
      EventFunctions.getNFTConfig.name,
    );
    // print('nftConfig $nftConfig');
    return NFTConfig.fromTuple(nftConfig);
  }

  Future<List<PackageConfig>> getPackageConfigs(String eventAddress) async {
    List packages = await WCService.to.read(
      _eventContract(eventAddress),
      EventFunctions.getPackageConfigs.name,
    );
    // print('packages $packages');
    return packages.map((e) => PackageConfig.fromTuple(e)).toList();
  }

  Future<List<int>> getPackageTicketsBought(
      String eventAddress, int packageId) async {
    List ticketsBought = await WCService.to.read(
      _eventContract(eventAddress),
      EventFunctions.getPackageTicketsBought.name,
      [BigInt.from(packageId)],
    );
    // print('ticketsBought $ticketsBought');
    return ticketsBought.map((e) => (e as BigInt).toInt()).toList();
  }

  Future<PackageConfig> getTicketPackageConfig(
      String eventAddress, int ticketId) async {
    List package = await WCService.to.read(
      _eventContract(eventAddress),
      EventFunctions.getTicketPackageConfig.name,
      [BigInt.from(ticketId)],
    );
    // print('package $package');
    return PackageConfig.fromTuple(package);
  }

  Future<List<int>> getTicketsValidated(String eventAddress) async {
    List ticketsValidated = await WCService.to.read(
      _eventContract(eventAddress),
      EventFunctions.getTicketsValidated.name,
    );
    // print('ticketsValidated $ticketsValidated');
    return ticketsValidated.map((e) => (e as BigInt).toInt()).toList();
  }

  Future<List<String>> getValidators(String eventAddress) async {
    List validators = await WCService.to.read(
      _eventContract(eventAddress),
      EventFunctions.getValidators.name,
    );
    // print('validators $validators');
    return validators.map((e) => e.toString()).toList();
  }

  Future<bool> isEventCanceled(String eventAddress) async {
    bool isCanceled = await WCService.to.read(
      _eventContract(eventAddress),
      EventFunctions.isEventCanceled.name,
    );
    // print('isCanceled $isCanceled');
    return isCanceled;
  }

  Future<String> tokenUri(String eventAddress, int ticketId) async {
    String tokenUri = await WCService.to.read(
      _eventContract(eventAddress),
      EventFunctions.tokenURI.name,
      [BigInt.from(ticketId)],
    );
    // print('tokenUri $tokenUri');
    return tokenUri;
  }
}
