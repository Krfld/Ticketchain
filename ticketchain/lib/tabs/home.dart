import 'package:flutter/material.dart';
import 'package:ticketchain/widgets/ticketchain_card.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Home'),
        TicketchainCard(),
      ],
    );
  }
}
