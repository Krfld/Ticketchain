import 'package:get/get.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/models/ticket.dart';
import 'package:ticketchain/services/event_service.dart';

class EventController extends GetxController {
  RxInt amount = RxInt(1);

  Future<bool> buyTickets(EventModel event, int packageId, int amount) async {
    List<int> ticketIds =
        event.ticketsAvailable(packageId).take(amount).toList();
    List<Ticket> tickets = [];
    for (int id in ticketIds) {
      tickets.add(await EventService.to.getTicket(event.address, id));
    }
    return await EventService.to.buyTickets(event.address, tickets);
  }
}
