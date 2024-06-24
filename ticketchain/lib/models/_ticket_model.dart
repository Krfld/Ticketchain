import 'package:ticketchain/models/_event_model.dart';
import 'package:ticketchain/models/_package_model.dart';

class TicketModel implements Comparable<TicketModel> {
  final EventModel event;
  final PackageModel package;
  final int amount;

  TicketModel(
    this.event,
    this.package,
    this.amount,
  );

  TicketModel.fromDoc(this.event, this.package, Map<String, dynamic> doc)
      : amount = doc['amount'] as int;

  @override
  int compareTo(TicketModel other) => event.compareTo(other.event);
}
