import 'package:get/get.dart';
import 'package:ticketchain/services/web3_service.dart';

class ValidatorController extends GetxController {
  Future<bool> validateTickets(
    String eventAddress,
    List<int> tickets,
    String ownerAddress,
  ) async {
    return await Web3Service.to
        .validateTickets(eventAddress, tickets, ownerAddress);
  }
}
