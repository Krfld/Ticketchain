import 'package:ticketchain/models/percentage.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class TicketchainConfig {
  final EthereumAddress ticketchainAddress;
  final Percentage feePercentage;

  TicketchainConfig(
    this.ticketchainAddress,
    this.feePercentage,
  );
}
