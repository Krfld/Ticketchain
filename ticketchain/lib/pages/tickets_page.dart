import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/ticket_card.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

class TicketsPage extends StatelessWidget {
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
      body: ObxValue(
        (ticketsSelected) => Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(32),
              child: Wrap(
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
                        onPressed: () => MapsLauncher.launchQuery(
                            event.eventConfig.location),
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
                  Wrap(
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
                          onTap: () => ticketsSelected.contains(ticket)
                              ? ticketsSelected.remove(ticket)
                              : ticketsSelected.add(ticket),
                          selected: ticketsSelected.contains(ticket),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (ticketsSelected.isNotEmpty)
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
                          //todo show modal with address input
                        },
                      ),
                      FloatingActionButton.extended(
                        icon: const Icon(Icons.attach_money_rounded),
                        label: const Text(
                          'Refund tickets',
                          style: TicketchainTextStyle.title,
                        ),
                        onPressed: () {
                          //todo show modal with confirmation button
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
        <Ticket>[].obs,
      ),
    );
  }
}
