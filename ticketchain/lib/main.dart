import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/pages/authentication/authentication_page.dart';
import 'package:ticketchain/pages/main/main_page.dart';
import 'package:ticketchain/pages/validator/validator_page.dart';
import 'package:ticketchain/services/wc_service.dart';
import 'package:ticketchain/services/web3_service.dart';
import 'package:ticketchain/theme/ticketchain_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ticketchain',
      theme: ticketchainTheme,
      home: Obx(
        () => WCService.to.isAuthenticated()
            ? const MainPage()
            : Web3Service.to.isAuthenticated()
                ? const ValidatorPage()
                : const AuthenticationPage(),
      ),
    );
  }
}
