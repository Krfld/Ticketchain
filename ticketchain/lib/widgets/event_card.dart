import 'package:flutter/material.dart';
import 'package:ticketchain/models/event_model.dart';
import 'package:ticketchain/widgets/ticketchain_card.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return TicketchainCard(
      title: event.name,
      subtitle: '${event.date.day}/${event.date.month}/${event.date.year}',
      icon: const Icon(Icons.event_rounded),
    );
  }
}
