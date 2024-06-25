class Package {
  final String name;
  final String description;
  final int price;
  final int supply;
  final bool individualNfts;

  Package(
    this.name,
    this.description,
    this.price,
    this.supply,
    this.individualNfts,
  );

  Package.fromTuple(List tuple)
      : name = tuple[0],
        description = tuple[1],
        price = tuple[2].toInt(),
        supply = tuple[3].toInt(),
        individualNfts = tuple[4];
}
