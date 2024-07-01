import 'dart:developer';

import 'package:get/get.dart';
import 'package:platform_device_id/platform_device_id.dart';

class ValidatorService extends GetxService {
  static ValidatorService get to =>
      Get.isRegistered() ? Get.find() : Get.put(ValidatorService._());
  ValidatorService._();

  RxBool isAuthenticated = false.obs;

  Future<void> authenticate() async {
    log((await PlatformDeviceId.getDeviceId).toString());
    //? find a way to always get the same wallet based on the device, instead of reliyng on storing it
    //todo create wallet and save it on the device
    isAuthenticated(true);
  }
}
