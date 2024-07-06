import 'package:ticketchain/models/event_config.dart';
import 'package:ticketchain/models/nft_config.dart';
import 'package:ticketchain/models/package.dart';

class EventModel {
  final String address;
  final EventConfig eventConfig;
  final List<PackageModel> packages;
  final NFTConfig nftConfig;
  final List<int> ticketsValidated;
  final bool isCanceled;

  EventModel(
    this.address,
    this.eventConfig,
    this.packages,
    this.nftConfig,
    this.ticketsValidated,
    this.isCanceled,
  );

  List<int> ticketsAvailable(int packageId) => List.generate(
        packages[packageId].packageConfig.supply,
        (index) =>
            index +
            packages.take(packageId).fold<int>(
                  0,
                  (previousValue, element) =>
                      previousValue + element.packageConfig.supply,
                ),
      )
          .where(
              (element) => !packages[packageId].ticketsBought.contains(element))
          .toList();

  bool get isOnline =>
      DateTime.now().isAfter(eventConfig.onlineDate) &&
      DateTime.now().isBefore(eventConfig.offlineDate) &&
      !isCanceled;

  bool get isSoldOut => packages.every((element) =>
      element.ticketsBought.length == element.packageConfig.supply);

  bool get isRefundable =>
      DateTime.now().isBefore(eventConfig.noRefundDate) &&
      eventConfig.refundPercentage > 0;
}
