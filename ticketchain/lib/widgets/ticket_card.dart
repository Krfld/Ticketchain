import 'package:flutter/material.dart';
import 'package:ticketchain/models/ticket_model.dart';
import 'package:ticketchain/widgets/ticketchain_card.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return const TicketchainCard(
      title: 'Ticket',
      subtitle: 'Event',
      icon: Icon(Icons.qr_code_rounded),
    );
  }
}
