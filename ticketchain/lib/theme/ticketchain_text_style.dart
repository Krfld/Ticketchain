import 'package:flutter/material.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';

class TicketchainTextStyle {
  static const TextStyle _title = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static TextStyle titleWhite = _title.copyWith(color: TicketchainColor.white);
  static TextStyle titleDarkGray = _title.copyWith(color: TicketchainColor.darkGray);

  static const TextStyle text = TextStyle(
    color: TicketchainColor.gray,
    fontSize: 16,
  );
}
