import 'package:flutter/material.dart';
import 'package:ticketchain/widgets/ticketchain_card.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 32),
      itemBuilder: (context, index) => const TicketchainCard(),
    );
  }
}
