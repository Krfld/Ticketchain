import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/pages/main/controllers/profile_controller.dart';

class ProfileSettingsController extends GetxController {
  final profileController = Get.put(ProfileController());
  final nameController = TextEditingController();

  Future<void> changeAvatar() async {}

  Future<void> saveChanges() async {}

  Future logOut() async {}
}
