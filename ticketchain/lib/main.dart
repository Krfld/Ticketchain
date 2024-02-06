import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/firebase_options.dart';
import 'package:ticketchain/pages/authentication_page.dart';
import 'package:ticketchain/pages/main_page.dart';
import 'package:ticketchain/services/authentication_service.dart';
import 'package:ticketchain/services/wallet_connect_service.dart';
import 'package:ticketchain/test_page.dart';
import 'package:ticketchain/theme/ticketchain_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // String eventsString = await rootBundle.loadString('assets/dummy/events.json');
  // for (var event in jsonDecode(eventsString) as List) {
  //   await FirebaseFirestore.instance.collection('events').add(event);
  // }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticationService = Get.put(AuthenticationService());
    return GetMaterialApp(
      title: 'Ticketchain',
      theme: ticketchainTheme,
      home: FutureBuilder(
        future: Future.delayed(1.seconds),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Scaffold(body: SizedBox.shrink())
                : Obx(
                    () => authenticationService.isAuthenticated()
                        ? const MainPage()
                        : const TestPage(), // AuthenticationPage(),
                  ),
      ),
    );
  }
}
