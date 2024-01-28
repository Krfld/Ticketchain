import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/user_model.dart';

class StorageService extends GetxService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<TaskSnapshot> saveAvatar(UserModel user, Uint8List avatar) async =>
      await _storage.ref(user.id).putData(avatar);

  Future<String> getAvatarUrl(UserModel user) async =>
      await _storage.ref(user.id).getDownloadURL();
}
