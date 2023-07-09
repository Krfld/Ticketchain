import 'package:ticketchain/models/package_model.dart';

class EventModel implements Comparable<EventModel> {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String location;
  List<PackageModel> packages = [];

  EventModel(
    this.id,
    this.name,
    this.description,
    this.date,
    this.location,
  );

  EventModel.fromDoc(this.id, Map<String, dynamic> doc)
      : name = doc['name'],
        description = doc['description'],
        date = DateTime.fromMillisecondsSinceEpoch(doc['date'] * 1000),
        location = doc['location'],
        packages = (doc['packages'] as List).map((e) => PackageModel.fromDoc(e as Map<String, dynamic>)).toList()..sort();

  @override
  int compareTo(EventModel other) => date.compareTo(other.date);
}
