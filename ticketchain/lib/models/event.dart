import 'package:ticketchain/models/event_config.dart';
import 'package:ticketchain/models/nft_config.dart';
import 'package:ticketchain/models/package.dart';

class EventModel {
  final String address;
  final String name;
  final String description;
  final String location;
  final DateTime date;
  final List<Package> packages;
  final NFTConfig nftConfig;

  EventModel(
    this.address,
    this.name,
    this.description,
    this.location,
    this.date,
    this.packages,
    this.nftConfig,
  );

  EventModel.load(
    this.address,
    EventConfig eventConfig,
    this.packages,
    this.nftConfig,
  )   : name = eventConfig.name,
        description = eventConfig.description,
        location = eventConfig.location,
        date = DateTime.fromMillisecondsSinceEpoch(
            eventConfig.date.toInt() * 1000);
}
