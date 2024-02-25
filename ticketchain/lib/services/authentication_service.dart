import 'package:get/get.dart';
import 'package:ticketchain/pages/authentication_page.dart';
import 'package:ticketchain/pages/main_page.dart';
import 'package:ticketchain/services/wallet_connect_service.dart';

class AuthenticationController extends GetxController {
  static AuthenticationController get to =>
      Get.isRegistered() ? Get.find() : Get.put(AuthenticationController._());
  AuthenticationController._();

  RxBool isAuthenticated = false.obs;

  Future<void> signIn() async {
    if (await WalletConnectService.to.authenticate()) {
      Get.offAll(() => const MainPage());
    }
  }

  Future<void> signOut() async {
    Get.offAll(() => const AuthenticationPage());
  }
}
