import 'package:get/get.dart';
import 'package:ticketchain/models/ticket_model.dart';

class ProfileController extends GetxController {
  @override
  void onInit() async {
    await getTickets();
    super.onInit();
  }

  RxList<TicketModel> tickets = RxList();

  Future getTickets() async {}
}
