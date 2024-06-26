import 'package:ticketchain/models/package_config.dart';

class PackageModel {
  final PackageConfig packageConfig;
  final List<int> ticketsBought;

  PackageModel(
    this.packageConfig,
    this.ticketsBought,
  );
}
