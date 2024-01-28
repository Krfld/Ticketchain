import 'package:get/get.dart';
import 'package:ticketchain/models/package_model.dart';
import 'package:ticketchain/services/ticketchain_service.dart';

class EventController extends GetxController {
  final ticketchainService = Get.put(TicketchainService());

  RxInt amount = RxInt(1);

  Future<void> buyTickets(PackageModel package, int amount) async =>
      ticketchainService.buyTickets(package, amount);
}
