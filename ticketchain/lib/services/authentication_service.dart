import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/user_model.dart';
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

    handleUser(_authentication.currentUser);

    super.onInit();
  }

  final FirebaseAuth _authentication = FirebaseAuth.instance;

  RxBool isAuthenticated = false.obs;
  UserModel? user;

  handleUser(User? currentUser) async {
    log(currentUser.toString());

    if (currentUser == null) {
      isAuthenticated(false);
      user = null;
      return;
    }

    String id = currentUser.uid;

    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(id);

    if (!(await userRef.get()).exists) {
      await userRef.set({
        'name': currentUser.displayName!.isEmpty ? 'user-$id' : currentUser.displayName,
        'email': currentUser.email,
        'avatarUrl': currentUser.photoURL!.replaceAll("s96-c", "s1024-c"),
      });
    }

    Map<String, dynamic> userData = (await userRef.get()).data() as Map<String, dynamic>;
    user = UserModel.fromMap(id, userData);

    isAuthenticated(true);
  }

  Future signIn() async {
    try {
      UserCredential userCredential = await _authentication.signInWithProvider(GoogleAuthProvider());

      handleUser(userCredential.user);

      Get.offAll(() => const MainPage());
    } catch (e) {
      log(e.toString());
    }
  }

  Future signOut() async {
    await _authentication.signOut();

    handleUser(null);

    Get.offAll(() => const AuthenticationPage());
  }
}
