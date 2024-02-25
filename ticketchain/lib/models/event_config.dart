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
}
