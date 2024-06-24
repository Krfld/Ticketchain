import 'package:get/get.dart';
import 'package:ticketchain/services/wallet_connect_service.dart';

class AuthenticationService extends GetxController {
  static AuthenticationService get to =>
      Get.isRegistered() ? Get.find() : Get.put(AuthenticationService._());
  AuthenticationService._();

  RxBool isAuthenticated = false.obs;

  Future<void> signIn() async {
    if (await WalletConnectService.to.authenticate()) {
      isAuthenticated.value = true;
      // Get.offAll(() => const MainPage());
    }
  }

  Future<void> signOut() async {
    await WalletConnectService.to.disconnect();
    isAuthenticated.value = false;
    // Get.offAll(() => const AuthenticationPage());
  }
}
