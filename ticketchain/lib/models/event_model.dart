class EventModel implements Comparable<EventModel> {
  final String name;
  final String description;
  final DateTime date;
  final String location;
  // final List<PackageModel> packages;

  EventModel(
    this.name,
    this.description,
    this.date,
    this.location,
    // this.packages,
  );

  EventModel.fromDoc(Map<String, dynamic> doc)
      : name = doc['name'] ?? '',
        description = doc['description'] ?? '',
        date = DateTime.fromMillisecondsSinceEpoch(doc['date'] * 1000) ?? DateTime.now(),
        location = doc['location'] ?? '';
  // packages = json['packages'].map((e) => PackageModel.fromJson(e)).toList() ?? [];

  @override
  int compareTo(EventModel other) => date.compareTo(other.date);
}
