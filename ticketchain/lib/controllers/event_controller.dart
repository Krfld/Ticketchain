import 'package:get/get.dart';
import 'package:ticketchain/models/package.dart';

class EventController extends GetxController {
  RxInt amount = RxInt(1);

  Future<bool> buyTickets(PackageModel package, int amount) async {
    return false;
  }
}
