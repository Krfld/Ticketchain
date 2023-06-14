import 'package:flutter/material.dart';
import 'package:ticketchain/models/event_model.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  const EventCard({super.key, required this.event});

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
                  'Event',
                  style: TicketchainTextStyle.titleDarkGray,
                ),
                const Text(
                  'Date',
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
