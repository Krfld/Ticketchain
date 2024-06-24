import 'package:get/get.dart';
import 'package:ticketchain/controllers/home_controller.dart';
import 'package:ticketchain/controllers/profile_controller.dart';
import 'package:ticketchain/tabs/home_tab.dart';
import 'package:ticketchain/tabs/profile_tab.dart';

class MainController extends GetxController {
  @override
  void onInit() {
    Get.put(HomeController()).getEvents();
    Get.put(ProfileController()).getTickets();
    super.onInit();
  }

  final List tabs = [
    const HomeTab(),
    const ProfileTab(),
  ];

  // changeTabs(int index) async {
  //   switch (index) {
  //     case 0:
  //       await Get.put(HomeController()).getEvents();
  //       break;
  //     case 1:
  //       await Get.put(ProfileController()).getTickets();
  //       break;
  //   }
  // }
}
