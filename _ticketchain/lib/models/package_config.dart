import 'package:web3modal_flutter/web3modal_flutter.dart';

class PackageConfig {
  final String name;
  final String description;
  final EtherAmount price;
  final int supply;
  final bool individualNfts;

  PackageConfig(
    this.name,
    this.description,
    this.price,
    this.supply,
    this.individualNfts,
  );

  PackageConfig.fromTuple(List tuple)
      : name = tuple[0],
        description = tuple[1],
        price = EtherAmount.inWei(tuple[2]),
        supply = tuple[3].toInt(),
        individualNfts = tuple[4];
}
