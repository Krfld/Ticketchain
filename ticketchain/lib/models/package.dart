import 'package:ticketchain/models/package_config.dart';

class PackageModel {
  final Package packageConfig;
  final List<int> ticketsBought;

  PackageModel(
    this.packageConfig,
    this.ticketsBought,
  );

  int get ticketsAvailable =>
      packageConfig.supply.toInt() - ticketsBought.length;
}
