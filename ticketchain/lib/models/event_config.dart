import 'package:ticketchain/models/percentage.dart';

class EventConfig {
  final String name;
  final String description;
  final String location;
  final BigInt date;
  final BigInt offlineDate;
  final BigInt noRefundDate;
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
        date = tuple[3],
        offlineDate = tuple[4],
        noRefundDate = tuple[5],
        refundPercentage = Percentage.fromTuple(tuple[6]);
}
