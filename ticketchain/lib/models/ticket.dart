import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/models/package_config.dart';

class Ticket {
  final int ticketId;

  final EventModel event;
  final PackageConfig package;

  Ticket(
    this.ticketId,
    this.event,
    this.package,
  );
}
