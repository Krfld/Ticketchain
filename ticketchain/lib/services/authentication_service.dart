import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ticketchain/pages/authentication_page.dart';
import 'package:ticketchain/pages/main_page.dart';

class AuthenticationService extends GetxService {
  @override
  void onInit() {
    // _authentication.authStateChanges().listen((User? user) {
    //   log('AuthenticationService - authStateChanges - user\n$user');
    //   isAuthenticated(user != null);
    //   this.user = user;
    // });

    isAuthenticated(_authentication.currentUser != null);
    user = _authentication.currentUser;

    super.onInit();
  }

  final FirebaseAuth _authentication = FirebaseAuth.instance;

  RxBool isAuthenticated = false.obs;
  User? user;

  Future signIn() async {
    try {
      UserCredential userCredential = await _authentication.signInWithProvider(GoogleAuthProvider());

      user = userCredential.user;
      isAuthenticated(true);

      Get.offAll(() => const MainPage());
    } catch (e) {
      log(e.toString());
    }
  }

  Future signOut() async {
    await _authentication.signOut();

    isAuthenticated(false);
    user = null;

    Get.offAll(() => const AuthenticationPage());
  }
}
