import 'dart:convert';

import 'package:eth_sig_util/util/bytes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/services/web3_service.dart';
import 'package:ticketchain/widgets/qr_code_modal.dart';

class ValidatorController extends GetxController {
  Future<void> validateTickets() async {
    String data =
        '${Web3Service.to.wallet.privateKey.address.hex} ${DateTime.now()}';
    final message = Web3Service.to.wallet.privateKey
        .signPersonalMessageToUint8List(utf8.encode(data));

    bool? value = await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => QrCodeModal(
        title: 'Show User',
        data: bufferToHex(message),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Scan User'),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );

    if (value != true) return;
  }
}
