class PackageModel implements Comparable<PackageModel> {
  final String eventId;
  final String name;
  final String description;
  final double price;

  PackageModel(
    this.eventId,
    this.name,
    this.description,
    this.price,
  );

  PackageModel.fromDoc(this.eventId, Map<String, dynamic> doc)
      : name = doc['name'],
        description = doc['description'],
        price = doc['price'] * 1.0;

  @override
  int compareTo(PackageModel other) => price.compareTo(other.price);
}
