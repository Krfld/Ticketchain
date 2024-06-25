import 'package:flutter/material.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/widgets/ticketchain_card.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return TicketchainCard(
      title: '#${ticket.id} | ${ticket.package.name}',
      subtitle: ticket.event.eventConfig.name,
      leading: const Icon(Icons.qr_code_rounded),
      hasTrailing: false,
      // onTap: () => EventPage(event: ticket.event),
    );
  }
}
