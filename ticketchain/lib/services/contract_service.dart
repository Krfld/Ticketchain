import 'package:get/get.dart';

class ContractService extends GetxService {
  static ContractService get to =>
      Get.isRegistered() ? Get.find() : Get.put(ContractService._());
  ContractService._();
}
