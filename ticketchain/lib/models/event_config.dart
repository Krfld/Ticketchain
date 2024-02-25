import 'package:ticketchain/models/percentage.dart';

class EventConfig {
  final int onlineDate;
  final int offlineDate;
  final int noRefundDate;
  final Percentage refundPercentage;

  EventConfig(
    this.onlineDate,
    this.offlineDate,
    this.noRefundDate,
    this.refundPercentage,
  );

  EventConfig.fromTuple(
    List tuple,
  )   : onlineDate = tuple[0],
        offlineDate = tuple[1],
        noRefundDate = tuple[2],
        refundPercentage = Percentage.fromTuple(tuple[3]);
}
