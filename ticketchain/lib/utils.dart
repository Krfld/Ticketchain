import 'dart:math';

import 'package:ticketchain/models/percentage.dart';

String formatDate(DateTime date) {
  return "${date.day}/${date.month}/${date.year}";
}

double getPercentage(Percentage percentage) {
  return percentage.value / (100 * pow(10, percentage.decimals));
}
