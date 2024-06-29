import 'package:flutter/material.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/widgets/ticketchain_card.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final Function()? onTap;
  final bool selected;
  final bool validated;

  const TicketCard({
    super.key,
    required this.ticket,
    this.onTap,
    this.selected = false,
    this.validated = false,
  });

  @override
  Widget build(BuildContext context) {
    return TicketchainCard(
      title: '#${ticket.ticketId}',
      subtitle: ticket.package.name,
      leading: const Icon(Icons.qr_code_2_rounded),
      trailing: validated ? const Icon(Icons.check_circle_rounded) : null,
      onTap: onTap,
      selected: selected,
    );
  }
}
