import 'package:flutter/material.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_typography.dart';

class EventCard extends StatelessWidget {
  final Event event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: const ButtonStyle(
        elevation: MaterialStatePropertyAll(8),
        padding: MaterialStatePropertyAll(EdgeInsets.all(24)),
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event',
                  style: TicketchainTypography.title,
                ),
                Text(
                  'Date',
                  style: TicketchainTypography.text,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: TicketchainColor.purple,
          ),
        ],
      ),
    );
  }
}
