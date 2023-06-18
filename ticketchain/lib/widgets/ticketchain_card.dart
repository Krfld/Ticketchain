import 'package:flutter/material.dart';

class TicketchainCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Icon? icon;

  const TicketchainCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {},
        title: Text(title),
        subtitle: Text(subtitle),
        leading: icon,
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
      ),
    );
  }
}
