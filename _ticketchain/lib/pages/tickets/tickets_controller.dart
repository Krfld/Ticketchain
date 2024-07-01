import 'dart:convert';
import 'dart:developer';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/services/event_service.dart';
import 'package:ticketchain/services/wc_service.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/loading_modal.dart';

class TicketsController extends GetxController {
  final recipientController = TextEditingController();

  RxList<Ticket> ticketsSelected = <Ticket>[].obs;

  Future<bool> giftTickets() async {
    return await EventService.to.giftTickets(
      ticketsSelected.first.event.address,
      recipientController.text,
      ticketsSelected,
    );
  }

  Future<bool> refundTickets() async {
    return await EventService.to.refundTickets(
      ticketsSelected.first.event.address,
      ticketsSelected,
    );
  }

  Future<void> validateTickets() async {
    final GlobalKey qrKey = GlobalKey();

    String? validatorScan = await showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Scan Validator'),
        content: SizedBox(
          height: Get.size.width,
          child: QRView(
            key: qrKey,
            onQRViewCreated: (qrController) {
              qrController.scannedDataStream.listen((scanData) {
                if (scanData.code != null) {
                  qrController.dispose();
                  Get.back(result: scanData.code!);
                }
              });
            },
          ),
        ),
      ),
    );

    if (validatorScan == null) return;

    Map data = {
      'tickets': ticketsSelected.map((ticket) => ticket.id).toList(),
      'address': WCService.to.address,
      'validator': validatorScan,
    };

    bool signed = await Get.showOverlay(
      asyncFunction: () async {
        try {
          String signature = await WCService.to.signMessage(jsonEncode(data));
          SignatureUtil.fromRpcSig(signature);

          data['signature'] = signature;
          return true;
        } catch (e) {
          log('catch validateTickets: $e');
          return false;
        }
      },
      loadingWidget: const LoadingModal(),
    );

    if (!signed) return;

    await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Show Validator'),
        content: SizedBox(
          width: Get.size.width,
          child: QrImageView(
            data: jsonEncode(data),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Close',
                style: TicketchainTextStyle.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
