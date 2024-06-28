import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:ticketchain/controllers/profile_controller.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/ticket_card.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class TicketsPage extends GetView<ProfileController> {
  final EventModel event;
  final List<Ticket> tickets;

  const TicketsPage({
    super.key,
    required this.event,
    required this.tickets,
  });

  @override
  Widget build(BuildContext context) {
    return TicketchainScaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.back(),
        child: const Icon(
          Icons.arrow_back_ios_rounded,
          size: 32,
        ),
      ),
      body: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10,
        children: [
          Text(
            event.eventConfig.name,
            style: TicketchainTextStyle.name,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                label: Text(event.eventConfig.location),
                icon: const Icon(Icons.place_rounded),
                onPressed: () =>
                    MapsLauncher.launchQuery(event.eventConfig.location),
              ),
              Text(
                '${event.eventConfig.date.day}/${event.eventConfig.date.month}/${event.eventConfig.date.year}',
                style: TicketchainTextStyle.text,
              ),
            ],
          ),
          Text(
            event.eventConfig.description,
            style: TicketchainTextStyle.text,
          ),
          const Divider(),
          Obx(
            () => Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 20,
              children: [
                Text(
                  'You have ${tickets.length} tickets:',
                  style: TicketchainTextStyle.textBold,
                ),
                ...tickets.map(
                  (ticket) => TicketCard(
                    ticket: ticket,
                    onTap: () => controller.ticketsSelected.contains(ticket)
                        ? controller.ticketsSelected.remove(ticket)
                        : controller.ticketsSelected.add(ticket),
                    selected: controller.ticketsSelected.contains(ticket),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
