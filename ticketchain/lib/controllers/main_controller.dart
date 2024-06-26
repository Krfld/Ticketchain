import 'package:get/get.dart';
import 'package:ticketchain/controllers/home_controller.dart';
import 'package:ticketchain/controllers/profile_controller.dart';
import 'package:ticketchain/tabs/home_tab.dart';
import 'package:ticketchain/tabs/profile_tab.dart';

class MainController extends GetxController {
  @override
  void onInit() {
    updateControllers();
    super.onInit();
  }

  Future<void> updateControllers() async {
    await Future.wait([
      Get.put(HomeController()).getEvents(),
      Get.put(ProfileController()).getTickets(),
    ]);
  }

  final List tabs = [
    const HomeTab(),
    const ProfileTab(),
  ];

  void onTabChange(int index) {
    switch (index) {
      case 0:
        Get.put(HomeController()).getEvents();
        break;
      case 1:
        Get.put(ProfileController()).getTickets();
        break;
    }
  }
}
