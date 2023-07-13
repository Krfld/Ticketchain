import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/user_model.dart';
import 'package:ticketchain/pages/authentication_page.dart';
import 'package:ticketchain/pages/main_page.dart';
import 'package:ticketchain/services/firestore_service.dart';

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
  final firestoreService = Get.put(FirestoreService());

  RxBool isAuthenticated = false.obs;
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  UserModel get user => _user()!;

  Future<void> handleUser(User? currentUser) async {
    log(currentUser.toString());

    if (currentUser == null) {
      isAuthenticated(false);
      _user(null);
      return;
    }

    String id = currentUser.uid;

    DocumentReference userRef = firestoreService.getDocumentRef('users', id);
    DocumentSnapshot userSnapshot = await userRef.get();

    if (!userSnapshot.exists) {
      await userRef.set({
        'name': currentUser.displayName!.isEmpty ? 'user-$id'.substring(0, 10) : currentUser.displayName,
        'email': currentUser.email,
        'avatarUrl': currentUser.photoURL!.replaceAll("s96-c", "s1024-c"),
      });
      userSnapshot = await userRef.get();
    }

    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
    _user(UserModel.fromMap(id, userData));
    isAuthenticated(true);
  }

  updateUser() async {
    Map<String, dynamic> userData = (await firestoreService.getDocumentRef('users', user.id).get()).data() as Map<String, dynamic>;
    _user(UserModel.fromMap(user.id, userData));
  }

  Future<void> signIn() async {
    try {
      UserCredential userCredential = await _authentication.signInWithProvider(GoogleAuthProvider());

      await handleUser(userCredential.user);

      Get.offAll(() => const MainPage());
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> signOut() async {
    await _authentication.signOut();

    await handleUser(null);

    Get.offAll(() => const AuthenticationPage());
  }
}
