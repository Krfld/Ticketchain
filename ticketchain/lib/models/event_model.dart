import 'package:ticketchain/models/location_model.dart';
import 'package:ticketchain/models/package_model.dart';

class EventModel implements Comparable<EventModel> {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final LocationModel location;
  final List<PackageModel> packages;

  EventModel(
    this.id,
    this.name,
    this.description,
    this.date,
    this.location,
    this.packages,
  );

  EventModel.fromDoc(this.id, Map<String, dynamic> doc)
      : name = doc['name'],
        description = doc['description'],
        date = DateTime.fromMillisecondsSinceEpoch(doc['date'] * 1000),
        location = LocationModel.fromDoc(doc['location']),
        packages = (doc['packages'] as List).map((e) => PackageModel.fromDoc((doc['packages'] as List).indexOf(e), id, e as Map<String, dynamic>)).toList()..sort();

  @override
  int compareTo(EventModel other) => date.compareTo(other.date);
}
