import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/models/package_config.dart';

class Ticket {
  final int id;

  final EventModel event;
  final Package package;

  Ticket(
    this.id,
    this.event,
    this.package,
  );
}
