import 'package:get/get.dart';
import 'package:ticketchain/models/ticket_model.dart';
import 'package:ticketchain/services/ticketchain_service.dart';

class ProfileController extends GetxController {
  @override
  void onInit() async {
    await getTickets();
    super.onInit();
  }

  final ticketchainService = Get.put(TicketchainService());

  RxList<TicketModel> tickets = RxList();

  Future getTickets() async {
    tickets(await ticketchainService.getTickets());
  }
}
