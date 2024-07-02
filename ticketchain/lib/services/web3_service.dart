import 'dart:developer';
import 'dart:math' as math;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:ticketchain/services/event_service.dart';
import 'package:ticketchain/services/wc_service.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class Web3Service extends GetxService {
  static Web3Service get to =>
      Get.isRegistered() ? Get.find() : Get.put(Web3Service._());
  Web3Service._();

  RxBool isAuthenticated = false.obs;

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  late Wallet wallet;

  Web3Client client = Web3Client(
    WCService.to.targetChain.rpcUrl,
    Client(),
  );

  Future<void> authenticate() async {
    String id = (await _deviceInfo.androidInfo).id;

    wallet = Wallet.createNew(
      EthPrivateKey.createRandom(math.Random(id.hashCode)),
      'ticketchain',
      math.Random.secure(),
    );

    // await validateTickets(
    //   '0x7a40bc7b849a9F963f3fD8c6364Fd9f701B817a1',
    //   [8],
    //   '0xe53b00C08979Af2374A7df886539E0Ad79d8cCCb',
    // );

    isAuthenticated(true);
  }

  Future<bool> validateTickets(
    String eventAddress,
    List<int> tickets,
    String ownerAddress,
  ) async {
    try {
      // await client.estimateGas(
      //   sender: wallet.privateKey.address,
      //   to: EthereumAddress.fromHex(eventAddress),
      //   data: EventService.to
      //       .getValidateTicketsTransaction(
      //         eventAddress,
      //         tickets,
      //         ownerAddress,
      //         wallet.privateKey,
      //       )
      //       .data,
      // );

      // String txHash =
      await client.sendTransaction(
        wallet.privateKey,
        EventService.to.getValidateTicketsTransaction(
          eventAddress,
          tickets,
          ownerAddress,
          wallet.privateKey,
        ),
        chainId: int.parse(WCService.to.targetChain.chainId),
      );
      return true; //await waitForTx(txHash);
    } catch (e) {
      log('catch validateTickets: $e');
      return false;
    }
  }

  Future<bool> waitForTx(String txHash) async {
    bool? status;
    await Future.doWhile(() async {
      Future.delayed(1.seconds);
      status = (await client.getTransactionReceipt(txHash))?.status;
      return status == null;
    });
    return status!;
  }
}
