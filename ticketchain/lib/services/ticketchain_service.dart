import 'package:get/get.dart';
import 'package:ticketchain/constants/ticketchain_abi.dart';
import 'package:ticketchain/services/wc_service.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

enum TicketchainFunctions {
  /// write

  /// read
  getEvents,
}

class TicketchainService extends GetxService {
  static TicketchainService get to =>
      Get.isRegistered() ? Get.find() : Get.put(TicketchainService._());
  TicketchainService._();

  final String _ticketchainAddress =
      '0x8cfd98BfD8FeD016660268AA544D6bb3faA6602b';

  DeployedContract _ticketchainContract() => DeployedContract(
        ContractAbi.fromJson(ticketchainAbi, 'Ticketchain'),
        EthereumAddress.fromHex(_ticketchainAddress),
      );

  Future<List<String>> getEventsAddress() async {
    List eventsAddress = await WCService.to
        .read(_ticketchainContract(), TicketchainFunctions.getEvents.name);
    // print('events $eventsAddress');
    return eventsAddress.map((e) => e.toString()).toList();
  }
}
