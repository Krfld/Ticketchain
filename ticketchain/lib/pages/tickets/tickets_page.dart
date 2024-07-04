import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/models/ticket_validation_data.dart';
import 'package:ticketchain/pages/main/controllers/main_controller.dart';
import 'package:ticketchain/pages/tickets/tickets_controller.dart';
import 'package:ticketchain/services/wc_service.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/event_details.dart';
import 'package:ticketchain/widgets/gift_tickets_modal.dart';
import 'package:ticketchain/widgets/loading_modal.dart';
import 'package:ticketchain/widgets/qr_code_modal.dart';
import 'package:ticketchain/widgets/ticket_card.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class TicketsPage extends GetView<TicketsController> {
  final EventModel event;
  final List<Ticket> tickets;

  const TicketsPage({
    super.key,
    required this.event,
    required this.tickets,
  });

  Future<void> _showGiftTicketsModal() async => await showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const GiftTicketsModal(),
        ),
      );

  Future<void> _showConfirmRefundModal() async => await showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: Text(
              'Refund ${controller.ticketsSelected.length} ticket${controller.ticketsSelected.length != 1 ? 's' : ''}?'),
          content: Text('You will get ${controller.ticketsSelected.fold(
                .0,
                (previousValue, element) =>
                    previousValue +
                    element.package.price.getValueInUnit(EtherUnit.ether),
              ) * event.eventConfig.refundPercentage} eth'),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            FloatingActionButton(
              onPressed: () => Get.back(result: false),
              backgroundColor: TicketchainColor.red,
              foregroundColor: TicketchainColor.white,
              child: const Icon(
                Icons.close_rounded,
                size: 32,
              ),
            ),
            FloatingActionButton(
              onPressed: () async {
                bool success = false;
                await Get.showOverlay(
                  asyncFunction: () async {
                    if (await controller.refundTickets()) {
                      Get.find<MainController>().updateControllers();
                      success = true;
                      Get.snackbar(
                        'Success',
                        'Tickets refunded successfully',
                        backgroundColor: TicketchainColor.lightPurple,
                        colorText: TicketchainColor.white,
                      );
                    } else {
                      Get.snackbar(
                        'Error',
                        'Failed to refund tickets',
                        backgroundColor: TicketchainColor.lightPurple,
                        colorText: TicketchainColor.white,
                      );
                    }
                  },
                  loadingWidget: const LoadingModal(),
                );
                Get.close(success ? 2 : 1);
              },
              backgroundColor: TicketchainColor.green,
              foregroundColor: TicketchainColor.white,
              child: const Icon(
                Icons.check_rounded,
                size: 32,
              ),
            ),
          ],
        ),
      );

  Future<void> _validateTickets() async {
    String? validatorMessage = await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Scan validator'),
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

    TicketValidationData? ticketValidationData = await Get.showOverlay(
      asyncFunction: () async {
        try {
          String signature = await WCService.to.signMessage(validatorMessage);
          SignatureUtil.fromRpcSig(signature);

          return TicketValidationData(
            event.address,
            controller.ticketsSelected.map((ticket) => ticket.id).toList(),
            WCService.to.address,
            signature,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Sign Failed',
            backgroundColor: TicketchainColor.lightPurple,
            colorText: TicketchainColor.white,
          );
          return null;
        }
      },
      loadingWidget: const LoadingModal(),
    );

    if (ticketValidationData == null) return;

    await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => QrCodeModal(
        title: 'Show Validator',
        data: ticketValidationData.toMessage(),
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

  @override
  Widget build(BuildContext context) {
    Get.put(TicketsController());
    return TicketchainScaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.back(),
        child: const Icon(
          Icons.arrow_back_ios_rounded,
          size: 32,
        ),
      ),
      body: Obx(
        () => Stack(
          children: [
            EventDetails(
              event: event,
              children: [
                Text(
                  'You have ${tickets.length} tickets:',
                  style: TicketchainTextStyle.textBold,
                ),
                ...tickets.map(
                  (ticket) => TicketCard(
                    ticket: ticket,
                    onTap: () => !controller.ticketsSelected.contains(ticket) &&
                            !event.isTicketValidated(ticket.id)
                        ? controller.ticketsSelected.add(ticket)
                        : controller.ticketsSelected.remove(ticket),
                    selected: controller.ticketsSelected.contains(ticket),
                    validated: event.isTicketValidated(ticket.id),
                  ),
                ),
              ],
            ),
            if (controller.ticketsSelected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    runSpacing: 10,
                    children: [
                      FloatingActionButton.extended(
                        icon: const Icon(Icons.card_giftcard_rounded),
                        label: const Text(
                          'Gift tickets',
                          style: TicketchainTextStyle.title,
                        ),
                        onPressed: () {
                          controller.recipientController.clear();
                          _showGiftTicketsModal();
                        },
                      ),
                      if (event.isRefundable)
                        FloatingActionButton.extended(
                          icon: const Icon(Icons.attach_money_rounded),
                          label: const Text(
                            'Refund tickets',
                            style: TicketchainTextStyle.title,
                          ),
                          onPressed: () => _showConfirmRefundModal(),
                        ),
                      FloatingActionButton.extended(
                        icon: const Icon(Icons.check_rounded),
                        label: const Text(
                          'Validate tickets',
                          style: TicketchainTextStyle.title,
                        ),
                        onPressed: () => _validateTickets(),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
