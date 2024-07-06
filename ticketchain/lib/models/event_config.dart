import 'package:ticketchain/models/percentage.dart';
import 'package:ticketchain/utils.dart';

class EventConfig {
  final String name;
  final String description;
  final String location;
  final DateTime onlineDate;
  final DateTime noRefundDate;
  final DateTime date;
  final DateTime offlineDate;
  final double refundPercentage;

  EventConfig(
    this.name,
    this.description,
    this.location,
    this.onlineDate,
    this.noRefundDate,
    this.date,
    this.offlineDate,
    this.refundPercentage,
  );

  EventConfig.fromTuple(List tuple)
      : name = tuple[0],
        description = tuple[1],
        location = tuple[2],
        onlineDate =
            DateTime.fromMillisecondsSinceEpoch(tuple[3].toInt() * 1000),
        noRefundDate =
            DateTime.fromMillisecondsSinceEpoch(tuple[4].toInt() * 1000),
        date = DateTime.fromMillisecondsSinceEpoch(tuple[5].toInt() * 1000),
        offlineDate =
            DateTime.fromMillisecondsSinceEpoch(tuple[6].toInt() * 1000),
        refundPercentage = getPercentage(Percentage.fromTuple(tuple[7]));
}
