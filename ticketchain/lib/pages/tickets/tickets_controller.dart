import 'dart:convert';
import 'dart:developer';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/services/event_service.dart';
import 'package:ticketchain/services/wc_service.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/widgets/loading_modal.dart';
import 'package:ticketchain/widgets/qr_code_modal.dart';

class TicketsController extends GetxController {
  final recipientController = TextEditingController();

  RxList<Ticket> ticketsSelected = <Ticket>[].obs;

  String get eventAddress => ticketsSelected.first.event.address;

  Future<bool> giftTickets() async {
    return await EventService.to.giftTickets(
      eventAddress,
      recipientController.text,
      ticketsSelected,
    );
  }

  Future<bool> refundTickets() async {
    return await EventService.to.refundTickets(
      eventAddress,
      ticketsSelected,
    );
  }

  Future<void> validateTickets() async {
    final GlobalKey qrKey = GlobalKey();

    String? validatorMessage = await showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Scan Validator'),
        content: SizedBox(
          height: Get.size.width,
          width: Get.size.width,
          child: QRView(
            key: qrKey,
            onQRViewCreated: (qrController) {
              qrController.scannedDataStream.listen((scanData) {
                if (scanData.code != null) {
                  qrController.dispose();
                  Get.back(
                    result: scanData.code!,
                    closeOverlays: true,
                  );
                }
              });
            },
          ),
        ),
      ),
    );

    if (validatorMessage == null) return;

    // if (validatorData.isBlank ?? true) {
    //   Get.snackbar(
    //     'Error',
    //     'Invalid validator QR code',
    //     backgroundColor: TicketchainColor.lightPurple,
    //     colorText: TicketchainColor.white,
    //   );
    //   return;
    // }

    Map? data = await Get.showOverlay(
      asyncFunction: () async {
        try {
          String signature = await WCService.to.signMessage(validatorMessage);
          SignatureUtil.fromRpcSig(signature);

          return {
            'eventAddress': eventAddress,
            'tickets': ticketsSelected.map((ticket) => ticket.id).toList(),
            'owner': WCService.to.address,
            'signature': signature,
          };
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to sign message',
            backgroundColor: TicketchainColor.lightPurple,
            colorText: TicketchainColor.white,
          );
          log('catch validateTickets: $e');
          return null;
        }
      },
      loadingWidget: const LoadingModal(),
    );

    if (data == null) return;

    await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => QrCodeModal(
        title: 'Show Validator',
        data: jsonEncode(data),
        actions: [
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
  }
}
