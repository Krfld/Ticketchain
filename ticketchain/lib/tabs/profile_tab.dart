import 'package:flutter/material.dart';
import 'package:ticketchain/models/ticket_model.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/ticket_card.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 75,
          backgroundImage: NetworkImage(
            'https://lh3.googleusercontent.com/a/AAcHTtdzvSpzCYbB0Y9WWKu21M2hQ2xy8FanVcheKEKBeg=s360-c-no',
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Rodrigo Dias',
          style: TicketchainTextStyle.titleWhite,
        ),
        const SizedBox(height: 20),
        TicketCard(ticket: TicketModel()),
        const SizedBox(height: 20),
        TicketCard(ticket: TicketModel()),
        const SizedBox(height: 20),
        TicketCard(ticket: TicketModel()),
        const SizedBox(height: 20),
        TicketCard(ticket: TicketModel()),
        const SizedBox(height: 20),
        TicketCard(ticket: TicketModel()),
      ],
    );
  }
}
