import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/models/package_config.dart';

class Ticket {
  final int id;

  final EventModel event;
  final PackageConfig package;
  final String tokenUri;

  Ticket(
    this.id,
    this.event,
    this.package,
    this.tokenUri,
  );
}
