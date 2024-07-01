import 'package:get/get.dart';
import 'package:ticketchain/pages/main/controllers/home_controller.dart';
import 'package:ticketchain/pages/main/controllers/profile_controller.dart';
import 'package:ticketchain/pages/main/tabs/home_tab.dart';
import 'package:ticketchain/pages/main/tabs/profile_tab.dart';

class MainController extends GetxController {
  @override
  void onInit() {
    updateControllers();
    super.onInit();
  }

  final List tabs = [
    const HomeTab(),
    const ProfileTab(),
  ];

  Future<void> updateControllers() async {
    await Future.wait([
      Get.put(HomeController()).getEvents(),
      Get.put(ProfileController()).getTickets(),
    ]);
  }
}
