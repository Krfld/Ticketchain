import 'package:ticketchain/models/event_config.dart';
import 'package:ticketchain/models/nft_config.dart';
import 'package:ticketchain/models/package.dart';

class EventModel {
  final String address;
  final EventConfig eventConfig;
  final List<PackageModel> packages;
  final NFTConfig nftConfig;

  EventModel(
    this.address,
    this.eventConfig,
    this.packages,
    this.nftConfig,
  );
}
