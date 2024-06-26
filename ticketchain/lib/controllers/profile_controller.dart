import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/models/package_config.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/services/event_service.dart';
import 'package:ticketchain/services/ticketchain_service.dart';
import 'package:ticketchain/services/wc_service.dart';

class ProfileController extends GetxController {
  // @override
  // void onInit() {
  //   getTickets();
  //   super.onInit();
  // }

  RxList<Ticket> tickets = RxList();

  Future<void> getTickets() async {
    tickets.clear();
    List<String> eventsAddress = await TicketchainService.to.getEventsAddress();

    Uri url = Uri.https(
      'deep-index.moralis.io',
      'api/v2.2/${WCService.to.address}/nft',
      {
        'chain': WCService.to.chainHexId,
        ...{
          for (int i = 0; i < eventsAddress.length; i++)
            'token_addresses[$i]': eventsAddress[i]
        },
      },
    );

    var result = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'X-API-Key':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJub25jZSI6IjUyM2U2OGMxLWNlYTUtNDc4Mi1iNzUwLTVjNzg3NGNiM2RkOCIsIm9yZ0lkIjoiMjk1NTUwIiwidXNlcklkIjoiMzAyNTI5IiwidHlwZUlkIjoiMzc1N2I5ZmItZGM2Yy00NTIwLWJmMjAtYjNiYzkyMGI3NTExIiwidHlwZSI6IlBST0pFQ1QiLCJpYXQiOjE3MTkyMjc2MzQsImV4cCI6NDg3NDk4NzYzNH0.4k5doHuuKnhOJPLidUKQp61CpSdicD_8Gf7EbH9spRc',
      },
    );

    List nftsInfo = jsonDecode(result.body)['result'];

    for (String eventAddress
        in nftsInfo.map((nft) => nft['token_address']).toSet()) {
      EventModel event = await EventService.to.getEvent(eventAddress);

      // int ticketsIndex = await EventService.to.balanceOf(
      //   eventAddress,
      //   WalletConnectService.to.address,
      // );

      for (int tokenId in nftsInfo
          .where((nft) => nft['token_address'] == eventAddress)
          .map((nft) => int.parse(nft['token_id']))) {
        // int ticketId = await EventService.to.tokenOfOwnerByIndex(
        //   eventAddress,
        //   WalletConnectService.to.address,
        //   ticketIndex,
        // );

        PackageConfig packageConfig =
            await EventService.to.getTicketPackageConfig(eventAddress, tokenId);

        Ticket ticket = Ticket(
          tokenId,
          event,
          packageConfig,
        );

        tickets.add(ticket);
      }
    }
  }
}
