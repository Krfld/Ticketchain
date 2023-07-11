import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ticketchain/models/user_model.dart';
import 'package:ticketchain/services/authentication_service.dart';

class ProfileController extends GetxController {
  final authenticationService = Get.put(AuthenticationService());

  UserModel get user => authenticationService.user!;

  String get avatarUrl => user.avatarUrl;

  Future changeAvatar() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    //todo upload image
    //todo update user
  }
}
