import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/main_controller.dart';
import 'package:ticketchain/controllers/tickets_controller.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/event_details.dart';
import 'package:ticketchain/widgets/gift_tickets_modal.dart';
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

  Future<bool> _showConfirmRefundModal() async {
    return await showDialog(
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
                onPressed: () async => Get.back(result: false),
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
                    loadingWidget: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  );
                  success ? Get.close(2) : Get.close(1);
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
        ) ??
        false;
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
                            !event.isTicketValidated(ticket.ticketId)
                        ? controller.ticketsSelected.add(ticket)
                        : controller.ticketsSelected.remove(ticket),
                    selected: controller.ticketsSelected.contains(ticket),
                    validated: event.isTicketValidated(ticket.ticketId),
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
                          onPressed: () {
                            _showConfirmRefundModal();
                          },
                        ),
                      FloatingActionButton.extended(
                        icon: const Icon(Icons.check_rounded),
                        label: const Text(
                          'Validate tickets',
                          style: TicketchainTextStyle.title,
                        ),
                        onPressed: () {
                          //todo define logic
                        },
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
