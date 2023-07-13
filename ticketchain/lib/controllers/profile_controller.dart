import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ticketchain/models/user_model.dart';
import 'package:ticketchain/services/authentication_service.dart';
import 'package:ticketchain/services/firestore_service.dart';
import 'package:ticketchain/services/storage_service.dart';

class ProfileController extends GetxController {
  final authenticationService = Get.put(AuthenticationService());
  final storageService = Get.put(StorageService());
  final firestoreService = Get.put(FirestoreService());

  UserModel get user => authenticationService.user;

  TextEditingController nameController = TextEditingController();

  bool get hasChanges => nameController.text != user.name;

  Future<void> changeAvatar() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    await storageService.saveAvatar(user, await image.readAsBytes());

    String avatarUrl = await storageService.getAvatarUrl(user);
    DocumentReference userRef = firestoreService.getDocumentRef('users', user.id);
    await userRef.update({
      'avatarUrl': avatarUrl
    });

    await authenticationService.updateUser();
  }

  Future<void> saveChanges() async {
    if (!hasChanges) return;

    DocumentReference userRef = firestoreService.getDocumentRef('users', user.id);
    await userRef.update({
      'name': nameController.text
    });

    await authenticationService.updateUser();
  }
}
