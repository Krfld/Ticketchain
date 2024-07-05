import 'package:get/get.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/services/event_service.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class EventController extends GetxController {
  RxInt amount = RxInt(1);

  Future<bool> buyTickets(EventModel event, int packageId, int amount) async {
    List<int> ticketIds =
        event.ticketsAvailable(packageId).take(amount).toList();
    return await EventService.to.buyTickets(
        event.address,
        ticketIds,
        EtherAmount.inWei(
            event.packages[packageId].packageConfig.price.getInWei *
                BigInt.from(amount)));
  }
}
