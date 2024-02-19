import 'package:get/get.dart';
import 'package:ticketchain/pages/authentication_page.dart';
import 'package:ticketchain/pages/main_page.dart';
import 'package:ticketchain/services/wallet_connect_service.dart';

class AuthenticationService extends GetxService {
  static AuthenticationService get put => Get.put(AuthenticationService());
  static AuthenticationService get find => Get.find();

  RxBool isAuthenticated = false.obs;

  Future<void> signIn() async {
    if (await WalletConnectService.find.authenticate()) {
      Get.offAll(() => const MainPage());
    }
  }

  Future<void> signOut() async {
    Get.offAll(() => const AuthenticationPage());
  }
}
