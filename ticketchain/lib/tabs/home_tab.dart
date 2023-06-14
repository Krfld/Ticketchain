import 'package:flutter/material.dart';
import 'package:ticketchain/models/event_model.dart';
import 'package:ticketchain/widgets/event_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EventCard(event: EventModel()),
        const SizedBox(height: 32),
        EventCard(event: EventModel()),
        const SizedBox(height: 32),
        EventCard(event: EventModel()),
        const SizedBox(height: 32),
        EventCard(event: EventModel()),
        const SizedBox(height: 32),
        EventCard(event: EventModel()),
        const SizedBox(height: 32),
        EventCard(event: EventModel()),
      ],
    );
    // ListView.separated(
    //   itemCount: 9,
    //   separatorBuilder: (context, index) => const SizedBox(height: 32),
    //   itemBuilder: (context, index) => const TicketchainCard(),
    // );
  }
}
