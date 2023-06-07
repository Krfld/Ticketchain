import 'package:flutter/material.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_typography.dart';

class TicketchainCard extends StatelessWidget {
  const TicketchainCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 75,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event',
                    style: TicketchainTypography.title,
                  ),
                  Text(
                    'Date',
                    style: TicketchainTypography.text,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: TicketchainColor.purple,
            ),
          ],
        ),
      ),
    );
  }
}
