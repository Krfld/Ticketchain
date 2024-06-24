class Package {
  final String name;
  final String description;
  final BigInt price;
  final BigInt supply;
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
        price = tuple[2],
        supply = tuple[3],
        individualNfts = tuple[4];
}
