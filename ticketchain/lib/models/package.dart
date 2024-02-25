class Package {
  final int price;
  final int supply;
  final bool individualNfts;

  Package(
    this.price,
    this.supply,
    this.individualNfts,
  );

  Package.fromTuple(
    List tuple,
  )   : price = tuple[0],
        supply = tuple[1],
        individualNfts = tuple[2];
}
