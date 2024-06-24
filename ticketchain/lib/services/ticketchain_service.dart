import 'package:get/get.dart';
import 'package:ticketchain/constants/ticketchain_abi.dart';
import 'package:ticketchain/services/wallet_connect_service.dart';
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
      '0x5835fDdaea150a57eD06703092E62f9a40867673';

  DeployedContract _ticketchainContract() => DeployedContract(
        ContractAbi.fromJson(ticketchainAbi, 'Ticketchain'),
        EthereumAddress.fromHex(_ticketchainAddress),
      );

  Future<List<String>> getEventsAddress() async {
    List eventsAddress = await WalletConnectService.to
        .read(_ticketchainContract(), TicketchainFunctions.getEvents.name);
    // print('events $eventsAddress');
    return eventsAddress.map((e) => e.toString()).toList();
  }
}
