import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/pages/authentication_page.dart';
import 'package:ticketchain/services/wallet_connect_service.dart';
import 'package:ticketchain/theme/ticketchain_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    WalletConnectService.to;
    return GetMaterialApp(
      title: 'Ticketchain',
      theme: ticketchainTheme,
      home: FutureBuilder(
        future: Future.delayed(1.seconds),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Scaffold(body: SizedBox.shrink())
                : const AuthenticationPage(),
      ),
    );
  }
}
