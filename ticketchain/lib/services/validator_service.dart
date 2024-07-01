import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class ValidatorService extends GetxService {
  static ValidatorService get to =>
      Get.isRegistered() ? Get.find() : Get.put(ValidatorService._());
  ValidatorService._();

  RxBool isAuthenticated = false.obs;

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<void> authenticate() async {
    String id = (await _deviceInfo.androidInfo).id;

    BigInt pk = generateNewPrivateKey(Random(id.hashCode));
    print(pk);

    //todo create wallet and save it on the device
    // isAuthenticated(true);
  }
}
