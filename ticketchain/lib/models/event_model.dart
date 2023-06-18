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

  EventModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'],
        date = DateTime.fromMillisecondsSinceEpoch(json['date'] * 1000),
        location = json['location'];

  // PackageModel.fromJson(json['packages']);

  @override
  int compareTo(EventModel other) => date.compareTo(other.date);
}
