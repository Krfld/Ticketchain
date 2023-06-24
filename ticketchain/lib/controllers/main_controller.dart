import 'package:get/get.dart';
import 'package:ticketchain/tabs/home_tab.dart';
import 'package:ticketchain/tabs/profile_tab.dart';

class MainController extends GetxController {
  final List tabs = [
    const HomeTab(),
    const ProfileTab(),
  ];
}
