import 'package:get/get.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/models/package.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/services/event_service.dart';
import 'package:ticketchain/services/ticketchain_service.dart';
import 'package:ticketchain/services/wallet_connect_service.dart';

class ProfileController extends GetxController {
  @override
  void onInit() async {
    await getTickets();
    super.onInit();
  }

  RxList<Ticket> tickets = RxList();

  Future<void> getTickets() async {
    List<Ticket> ticketsTemp = [];
    List<String> eventsAddress = await TicketchainService.to.getEventsAddress();

    //todo get nfts with moralis

    //todo get events from the nfts that are in the ticketchain

    for (String eventAddress in eventsAddress.where((eventAddress) => true)) {
      EventModel event = await EventService.to.getEvent(eventAddress);

      int ticketsIndex = await EventService.to.balanceOf(
        eventAddress,
        WalletConnectService.to.address,
      );

      for (int ticketIndex = 0; ticketIndex < ticketsIndex; ticketIndex++) {
        int ticketId = await EventService.to.tokenOfOwnerByIndex(
          eventAddress,
          WalletConnectService.to.address,
          ticketIndex,
        );

        Package package =
            await EventService.to.getTicketPackage(eventAddress, ticketId);

        ticketsTemp.add(Ticket(
          ticketId,
          event,
          package,
        ));
      }
    }

    print('tickets $ticketsTemp');
    tickets.assignAll(ticketsTemp);
  }
}
