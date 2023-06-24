import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/event_model.dart';
import 'package:ticketchain/pages/event_page.dart';
import 'package:ticketchain/widgets/ticketchain_card.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return TicketchainCard(
      title: event.name,
      subtitle: '${event.date.day}/${event.date.month}/${event.date.year}',
      leading: const Icon(Icons.event_rounded),
      onTap: () => Get.to(() => EventPage(event: event)),
    );
  }
}
