import 'dart:convert';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/models/ticket_validation_data.dart';
import 'package:ticketchain/pages/main/controllers/main_controller.dart';
import 'package:ticketchain/pages/tickets/tickets_controller.dart';
import 'package:ticketchain/services/event_service.dart';
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

  Future<void> _showTicketModal(Ticket ticket) async => await showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: Text('Ticket #${ticket.id}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ticket.package.name),
              const Gap(16),
              Center(
                child: FutureBuilder(
                  future:
                      EventService.to.tokenUri(ticket.event.address, ticket.id),
                  builder: (context, snapshot) => Image.network(
                    snapshot.data ?? '',
                    loadingBuilder: (context, child, loadingProgress) =>
                        loadingProgress == null
                            ? child
                            : const CircularProgressIndicator(),
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

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
                await Get.showOverlay(
                  asyncFunction: () async {
                    if (await controller.refundTickets()) {
                      Get.find<MainController>().updateControllers();
                      Get.close(2);
                      Get.snackbar(
                        'Success',
                        'Tickets refunded successfully',
                        backgroundColor: TicketchainColor.lightPurple,
                        colorText: TicketchainColor.white,
                      );
                    } else {
                      Get.back();
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

    try {
      List validatorMessageParts = validatorMessage.split('|');
      EthereumAddress.fromHex(validatorMessageParts.first);
      DateTime.parse(validatorMessageParts.last);
    } catch (_) {
      Get.snackbar(
        'Error',
        'Invalid validator QR code',
        backgroundColor: TicketchainColor.lightPurple,
        colorText: TicketchainColor.white,
      );
      return;
    }

    TicketValidationData? ticketValidationData = await Get.showOverlay(
      asyncFunction: () async {
        try {
          String signature = await WCService.to
              .signMessage(bytesToHex(utf8.encode(validatorMessage)));
          SignatureUtil.fromRpcSig(signature);

          return TicketValidationData(
            event.address,
            controller.ticketsSelected.map((ticket) => ticket.id).toList(),
            WCService.to.address,
            signature,
          );
        } catch (_) {
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
    return Obx(
      () => TicketchainScaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: controller.selecting()
            ? null
            : FloatingActionButton(
                onPressed: () => Get.back(),
                child: const Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 32,
                ),
              ),
        body: Stack(
          children: [
            EventDetails(
              event: event,
              children: [
                Text(
                  'You have ${tickets.length} ticket${tickets.length != 1 ? 's' : ''}:',
                  style: TicketchainTextStyle.textBold,
                ),
                ...tickets
                    .where((ticket) =>
                        !controller.selecting() ? true : !ticket.isValidated)
                    .map(
                      (ticket) => TicketCard(
                        ticket: ticket,
                        onTap: () => controller.selecting()
                            ? !controller.ticketsSelected.contains(ticket) &&
                                    !ticket.isValidated
                                ? controller.ticketsSelected.add(ticket)
                                : controller.ticketsSelected.remove(ticket)
                            : _showTicketModal(ticket),
                        selected: controller.ticketsSelected.contains(ticket),
                        validated: ticket.isValidated,
                        selecting: controller.selecting(),
                      ),
                    ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Align(
                alignment: !controller.selecting()
                    ? Alignment.bottomRight
                    : Alignment.bottomRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  runSpacing: 10,
                  children: [
                    if (controller.ticketsSelected.isNotEmpty) ...[
                      FloatingActionButton.extended(
                        heroTag: 'gift',
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
                          heroTag: 'refund',
                          icon: const Icon(Icons.attach_money_rounded),
                          label: const Text(
                            'Refund tickets',
                            style: TicketchainTextStyle.title,
                          ),
                          onPressed: () => _showConfirmRefundModal(),
                        ),
                      FloatingActionButton.extended(
                        heroTag: 'validate',
                        icon: const Icon(Icons.check_rounded),
                        label: const Text(
                          'Validate tickets',
                          style: TicketchainTextStyle.title,
                        ),
                        onPressed: () => _validateTickets(),
                      ),
                    ],
                    if (controller.selecting()) ...[
                      if (controller.ticketsSelected.length !=
                          controller.ticketsNotValidated(tickets).length)
                        FloatingActionButton.extended(
                          heroTag: 'selected',
                          icon: const Icon(Icons.check_box_rounded),
                          label: const Text(
                            'Select all',
                            style: TicketchainTextStyle.title,
                          ),
                          onPressed: () => controller.ticketsSelected.assignAll(
                              controller.ticketsNotValidated(tickets)),
                        )
                      else
                        FloatingActionButton.extended(
                          heroTag: 'selected',
                          icon:
                              const Icon(Icons.indeterminate_check_box_rounded),
                          label: const Text(
                            'Deselect all',
                            style: TicketchainTextStyle.title,
                          ),
                          onPressed: () => controller.ticketsSelected.clear(),
                        ),
                      FloatingActionButton.extended(
                        heroTag: 'selecting',
                        icon: const Icon(Icons.deselect_rounded),
                        label: const Text(
                          'Deselect tickets',
                          style: TicketchainTextStyle.title,
                        ),
                        onPressed: () {
                          controller.ticketsSelected.clear();
                          controller.selecting(false);
                        },
                      )
                    ] else if (controller
                        .ticketsNotValidated(tickets)
                        .isNotEmpty)
                      FloatingActionButton.extended(
                        heroTag: 'selecting',
                        icon: const Icon(Icons.select_all_rounded),
                        label: const Text(
                          'Select tickets',
                          style: TicketchainTextStyle.title,
                        ),
                        onPressed: () => controller.selecting(true),
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
