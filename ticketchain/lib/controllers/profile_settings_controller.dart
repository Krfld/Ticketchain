import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/controllers/profile_controller.dart';
import 'package:ticketchain/services/firestore_service.dart';
import 'package:ticketchain/services/storage_service.dart';

class ProfileSettingsController extends GetxController {
  final profileController = Get.put(ProfileController());
  final storageService = Get.put(StorageService());
  final firestoreService = Get.put(FirestoreService());
  final nameController = TextEditingController();

  Future<void> changeAvatar() async {}

  Future<void> saveChanges() async {}

  Future logOut() async {}
}
