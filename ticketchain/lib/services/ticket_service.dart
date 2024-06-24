import 'package:get/get.dart';

class TicketService extends GetxService {
  static TicketService get to =>
      Get.isRegistered() ? Get.find() : Get.put(TicketService._());
  TicketService._();
}
