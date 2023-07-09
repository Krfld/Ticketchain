class PackageModel implements Comparable<PackageModel> {
  final String name;
  final double price;

  PackageModel(
    this.name,
    this.price,
  );

  PackageModel.fromDoc(Map<String, dynamic> doc)
      : name = doc['name'],
        price = doc['price'] * 1.0;

  @override
  int compareTo(PackageModel other) => price.compareTo(other.price);
}
