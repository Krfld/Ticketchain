import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/models/package_config.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/services/event_service.dart';
import 'package:ticketchain/services/ticketchain_service.dart';
import 'package:ticketchain/services/wc_service.dart';

class ProfileController extends GetxController {
  bool loading = false;

  RxMap<EventModel, List<Ticket>> tickets = RxMap();

  Future<void> getTickets() async {
    if (loading) return;
    loading = true;

    try {
      Map<EventModel, List<Ticket>> ticketsTemp = {};
      List<String> eventsAddress =
          await TicketchainService.to.getEventsAddress();

      Uri uri = Uri.https(
        'base-sepolia.g.alchemy.com',
        'nft/v3/xXtfF_qzcGw5k0BaNIwqF0YokA1lWyb_/getNFTsForOwner',
        {
          'owner': WCService.to.address,
          'contractAddresses[]': eventsAddress.join(','),
        },
      );

      var result = await http.get(uri);

      List nftsInfo = jsonDecode(result.body)['ownedNfts'];

      for (String eventAddress
          in nftsInfo.map((nft) => nft['contract']['address']).toSet()) {
        EventModel event = await EventService.to.getEvent(eventAddress);

        ticketsTemp.putIfAbsent(event, () => []);

        for (int tokenId in nftsInfo
            .where((nft) => nft['contract']['address'] == eventAddress)
            .map((nft) => int.parse(nft['tokenId']))) {
          PackageConfig packageConfig = await EventService.to
              .getTicketPackageConfig(eventAddress, tokenId);

          Ticket ticket = Ticket(
            tokenId,
            event,
            packageConfig,
          );

          ticketsTemp[event]!.add(ticket);
        }
      }

      tickets.assignAll(ticketsTemp);
    } catch (e) {
      log('catch getTickets: $e');
    }

    loading = false;
  }
}
