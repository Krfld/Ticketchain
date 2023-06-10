import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/firebase_options.dart';
import 'package:ticketchain/screens/body.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ticketchain',
      theme: ThemeData(
        shadowColor: TicketchainColor.black,
        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(
            iconColor: MaterialStatePropertyAll(TicketchainColor.purple),
            iconSize: MaterialStatePropertyAll(48),
          ),
        ),
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(TicketchainColor.white),
            surfaceTintColor: MaterialStatePropertyAll(TicketchainColor.transparent),
            elevation: MaterialStatePropertyAll(8),
            padding: MaterialStatePropertyAll(EdgeInsets.all(24)),
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: TicketchainColor.white,
          foregroundColor: TicketchainColor.purple,
          iconSize: 48,
          elevation: 8,
          sizeConstraints: BoxConstraints.tight(const Size.square(75)),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(75))),
        ),
        bottomAppBarTheme: const BottomAppBarTheme(
          color: TicketchainColor.white,
          surfaceTintColor: TicketchainColor.transparent,
          shadowColor: TicketchainColor.black,
          elevation: 8,
          padding: EdgeInsets.zero,
        ),
        useMaterial3: true,
      ),
      home: Body(),
    );
  }
}
