import 'package:ticketchain/models/percentage.dart';

class TicketchainConfig {
  final String ticketchainAddress;
  final Percentage feePercentage;

  TicketchainConfig(
    this.ticketchainAddress,
    this.feePercentage,
  );
}
