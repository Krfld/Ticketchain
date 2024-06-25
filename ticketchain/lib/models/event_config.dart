import 'package:ticketchain/models/percentage.dart';

class EventConfig {
  final String name;
  final String description;
  final String location;
  final DateTime date;
  final int offlineDate;
  final int noRefundDate;
  final Percentage refundPercentage;

  EventConfig(
    this.name,
    this.description,
    this.location,
    this.date,
    this.offlineDate,
    this.noRefundDate,
    this.refundPercentage,
  );

  EventConfig.fromTuple(List tuple)
      : name = tuple[0],
        description = tuple[1],
        location = tuple[2],
        date = DateTime.fromMillisecondsSinceEpoch(tuple[3].toInt() * 1000),
        offlineDate = tuple[4].toInt(),
        noRefundDate = tuple[5].toInt(),
        refundPercentage = Percentage.fromTuple(tuple[6]);
}
