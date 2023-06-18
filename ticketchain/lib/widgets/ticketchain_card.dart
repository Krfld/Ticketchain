import 'package:flutter/material.dart';

class TicketchainCard extends StatelessWidget {
  final Text title;
  final Text subtitle;
  final Icon? leading;
  final Function()? onTap;

  const TicketchainCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
      ),
    );
  }
}
