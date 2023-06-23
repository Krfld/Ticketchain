import 'package:flutter/material.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';

class TicketchainTextStyle {
  static const TextStyle heading = TextStyle(
    color: TicketchainColor.darkGray,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle title = TextStyle(
    color: TicketchainColor.darkGray,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitle = TextStyle(
    color: TicketchainColor.gray,
    fontSize: 16,
  );

  static const TextStyle name = TextStyle(
    color: TicketchainColor.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
}
