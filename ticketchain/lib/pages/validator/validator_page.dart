import 'dart:convert';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ticketchain/models/event_config.dart';
import 'package:ticketchain/models/ticket_validation_data.dart';
import 'package:ticketchain/pages/validator/validator_controller.dart';
import 'package:ticketchain/services/event_service.dart';
import 'package:ticketchain/services/web3_service.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/loading_modal.dart';
import 'package:ticketchain/widgets/qr_code_modal.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class ValidatorPage extends GetView<ValidatorController> {
  const ValidatorPage({super.key});

  Future<void> _showAddressQrCodeModal() async => await showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) => QrCodeModal(
          title: 'Validator Address',
          data: Web3Service.to.wallet.privateKey.address.hex,
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

  Future<void> _validateTickets() async {
    String message = bytesToHex(Web3Service.to.wallet.privateKey
        .signPersonalMessageToUint8List(utf8.encode(
            '${Web3Service.to.wallet.privateKey.address.hex} ${DateTime.now()}')));

    bool scan = await showDialog(
          context: Get.context!,
          barrierDismissible: false,
          builder: (context) => QrCodeModal(
            title: 'Show User',
            data: message,
            actions: [
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Scan User'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ],
          ),
        ) ??
        false;

    if (!scan) return;

    String? userMessage = await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Scan user'),
        content: SizedBox(
          height: Get.size.width,
          width: Get.size.width,
          child: QRView(
            key: GlobalKey(),
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

    if (userMessage == null) return;

    TicketValidationData ticketValidationData;
    try {
      ticketValidationData = TicketValidationData.fromMessage(userMessage);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid QR Code',
        backgroundColor: TicketchainColor.lightPurple,
        colorText: TicketchainColor.white,
      );
      return;
    }

    try {
      String ownerAddressRecovered = EthSigUtil.recoverPersonalSignature(
        signature: ticketValidationData.signature,
        message: utf8.encode(message),
      );

      if (ownerAddressRecovered != ticketValidationData.ownerAddress) throw '';
    } catch (_) {
      Get.snackbar(
        'Error',
        'Wrong User Signature',
        backgroundColor: TicketchainColor.lightPurple,
        colorText: TicketchainColor.white,
      );
      return;
    }

    EventConfig? eventConfig = await Get.showOverlay(
      asyncFunction: () async {
        try {
          return await EventService.to
              .getEventConfig(ticketValidationData.eventAddress);
        } catch (_) {
          Get.snackbar(
            'Error',
            'Event Not Found',
            backgroundColor: TicketchainColor.lightPurple,
            colorText: TicketchainColor.white,
          );
        }
        Get.close(1);
        return null;
      },
      loadingWidget: const LoadingModal(),
    );

    if (eventConfig == null) return;

    if (await controller.validateTickets(
      ticketValidationData.eventAddress,
      ticketValidationData.tickets,
      ticketValidationData.ownerAddress,
    )) {
      await showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            'Validated ${ticketValidationData.tickets.length} ticket${ticketValidationData.tickets.length != 1 ? 's' : ''}',
            style: TicketchainTextStyle.title,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                eventConfig.name,
                style: TicketchainTextStyle.title,
              ),
              const Divider(),
              Text(
                'Tickets:',
                style: TicketchainTextStyle.textBold
                    .copyWith(color: TicketchainColor.darkGray),
              ),
              Text(
                ticketValidationData.tickets.toString(),
                style: TicketchainTextStyle.subtitle,
              ),
              const Divider(),
              Text(
                'Owner Address:',
                style: TicketchainTextStyle.textBold
                    .copyWith(color: TicketchainColor.darkGray),
              ),
              Text(
                ticketValidationData.ownerAddress,
                style: TicketchainTextStyle.subtitle,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
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
    } else {
      Get.snackbar(
        'Error',
        'Tickets Not Validated',
        backgroundColor: TicketchainColor.lightPurple,
        colorText: TicketchainColor.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.put(ValidatorController());
    return TicketchainScaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: IntrinsicWidth(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FloatingActionButton.extended(
                  onPressed: () => _showAddressQrCodeModal(),
                  label: const Text('Validator Address'),
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                ),
                const Gap(16),
                FloatingActionButton.extended(
                  onPressed: () => _validateTickets(),
                  label: const Text('Validate Tickets'),
                  icon: const Icon(Icons.check_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
