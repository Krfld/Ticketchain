import 'package:flutter/material.dart';
import 'package:ticketchain/models/ticket_model.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ticket',
                  style: TicketchainTextStyle.titleDarkGray,
                ),
                const Text(
                  'Event',
                  style: TicketchainTextStyle.text,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded),
        ],
      ),
    );
  }
}
