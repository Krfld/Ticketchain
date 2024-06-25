import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/pages/event_page.dart';
import 'package:ticketchain/widgets/ticketchain_card.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return TicketchainCard(
      title: event.eventConfig.name,
      subtitle:
          '${event.eventConfig.date.day}/${event.eventConfig.date.month}/${event.eventConfig.date.year}',
      leading: const Icon(Icons.event_rounded),
      onTap: () => Get.to(() => EventPage(event: event)),
    );
  }
}
