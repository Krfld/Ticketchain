class PackageModel {
  final String name;
  final double price;

  PackageModel(
    this.name,
    this.price,
  );

  PackageModel.fromDoc(Map<String, dynamic> doc)
      : name = doc['name'] ?? '',
        price = doc['price'] ?? 0;

  // @override
  // int compareTo(EventModel other) => date.compareTo(other.date);
}
