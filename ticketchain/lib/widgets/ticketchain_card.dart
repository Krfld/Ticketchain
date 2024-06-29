import 'package:flutter/material.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';

class TicketchainCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Icon? leading;
  final Icon? trailing;
  final Function()? onTap;
  // final bool hasTrailing;
  final bool selected;

  const TicketchainCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing = const Icon(Icons.arrow_forward_ios_rounded),
    this.onTap,
    // this.hasTrailing = true,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: selected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                color: TicketchainColor.lightPurple,
                width: 4,
              ),
            )
          : null,
      child: ListTile(
        onTap: onTap,
        title: Text(title),
        subtitle: Text(subtitle),
        leading: leading,
        trailing: trailing,
      ),
    );
  }
}
