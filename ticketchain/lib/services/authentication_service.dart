import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthenticationService extends GetxService {
  @override
  void onInit() {
    _authentication.authStateChanges().listen((User? user) {
      log('AuthenticationService - authStateChanges - user\n$user');
      isAuthenticated(user != null);
      this.user = user;
    });
    super.onInit();
  }

  final FirebaseAuth _authentication = FirebaseAuth.instance;

  RxBool isAuthenticated = false.obs;
  User? user;

  Future signIn() async {
    await _authentication.signInWithProvider(GoogleAuthProvider());
  }

  Future signOut() async {
    await _authentication.signOut();
  }
}
