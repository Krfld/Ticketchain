import 'package:get/get.dart';
import 'package:ticketchain/models/event_model.dart';
import 'package:ticketchain/models/package_model.dart';
import 'package:ticketchain/models/ticket_model.dart';

class TicketchainService extends GetxService {
  Future<List<EventModel>> getEvents() async {
    List<EventModel> docs = [];
    return docs;
  }

  Future<List<TicketModel>> getTickets() async {
    List<TicketModel> tickets = [];
    return tickets;
  }

  Future<void> buyTickets(PackageModel package, int amount) async {}
}
