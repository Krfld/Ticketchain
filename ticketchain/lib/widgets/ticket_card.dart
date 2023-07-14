import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/ticket_model.dart';
import 'package:ticketchain/pages/event_page.dart';
import 'package:ticketchain/widgets/ticketchain_card.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return TicketchainCard(
      title: ticket.event.name,
      subtitle: ticket.package.name,
      leading: const Icon(Icons.qr_code_rounded),
      onTap: () => Get.to(() => EventPage(event: ticket.event)),
    );
  }
}
