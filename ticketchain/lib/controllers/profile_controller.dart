import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ticketchain/services/authentication_service.dart';

class ProfileController extends GetxController {
  final authenticationService = Get.put(AuthenticationService());

  User get user => authenticationService.user!;

  String get avatar => user.photoURL!.replaceAll("s96-c", "s1024-c");
}
