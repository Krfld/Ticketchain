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
import 'package:web3modal_flutter/web3modal_flutter.dart';

enum EventFunctions {
  /// write
  buyTickets,
  giftTickets,
  refundTickets,

  /// read
  balanceOf,
  getEventConfig,
  getNFTConfig,
  getPackageConfigs,
  getPackageTicketsBought,
  getTicketPackageConfig,
  tokenOfOwnerByIndex,
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
    EventConfig eventConfig = await getEventConfig(eventAddress);
    NFTConfig nftConfig = await getNFTConfig(eventAddress);
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
    EventModel event =
        EventModel(eventAddress, eventConfig, packages, nftConfig);
    return event;
  }

  // ----------------------------------------------------------------------------------------------------
  // Write ----------------------------------------------------------------------------------------------
  // ----------------------------------------------------------------------------------------------------

  Future<bool> buyTickets(String eventAddress, List<Ticket> tickets) async {
    try {
      await WCService.to.write(
        _eventContract(eventAddress),
        EventFunctions.buyTickets.name,
        parameters: [
          EthereumAddress.fromHex(WCService.to.address),
          tickets.map((e) => BigInt.from(e.ticketId)).toList(),
        ],
        value: tickets.fold(
          EtherAmount.zero(),
          (previousValue, element) => EtherAmount.inWei(
              previousValue!.getInWei + element.package.price),
        ),
      );
      return true;
    } catch (e) {
      log('error buyTickets $e');
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

  Future<int> tokenOfOwnerByIndex(
      String eventAddress, String address, int index) async {
    BigInt ticketId = await WCService.to.read(
      _eventContract(eventAddress),
      EventFunctions.tokenOfOwnerByIndex.name,
      [EthereumAddress.fromHex(address), BigInt.from(index)],
    );
    // print('ticketId $ticketId');
    return ticketId.toInt();
  }
}
