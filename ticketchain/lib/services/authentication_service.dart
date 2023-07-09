import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthenticationService extends GetxService {
  @override
  void onInit() {
    _authentication.authStateChanges().listen((User? user) {
      log('AuthenticationService - authStateChanges - user\n$user');
      isAuthenticated.value = user != null;
    });
    super.onInit();
  }

  final FirebaseAuth _authentication = FirebaseAuth.instance;

  RxBool isAuthenticated = false.obs;

  Future signIn() async {
    var x = await _authentication.signInWithProvider(GoogleAuthProvider());
    log(x.toString());
  }
}
