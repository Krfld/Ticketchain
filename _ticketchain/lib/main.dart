import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/pages/authentication/authentication_page.dart';
import 'package:ticketchain/pages/main/main_page.dart';
import 'package:ticketchain/services/validator_service.dart';
import 'package:ticketchain/services/wc_service.dart';
import 'package:ticketchain/theme/ticketchain_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    WCService.to;
    return GetMaterialApp(
      title: 'Ticketchain',
      theme: ticketchainTheme,
      home: Obx(
        () => WCService.to.isAuthenticated()
            ? const MainPage()
            : ValidatorService.to.isAuthenticated()
                ? const Placeholder()
                : const AuthenticationPage(),
      ),
    );
  }
}
