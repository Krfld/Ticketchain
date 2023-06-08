import 'package:flutter/material.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/widgets/event_card.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EventCard(event: Event()),
        const SizedBox(height: 32),
        EventCard(event: Event()),
        const SizedBox(height: 32),
        EventCard(event: Event()),
        const SizedBox(height: 32),
        EventCard(event: Event()),
        const SizedBox(height: 32),
        EventCard(event: Event()),
        const SizedBox(height: 32),
        EventCard(event: Event()),
      ],
    );
    // ListView.separated(
    //   itemCount: 9,
    //   separatorBuilder: (context, index) => const SizedBox(height: 32),
    //   itemBuilder: (context, index) => const TicketchainCard(),
    // );
  }
}
