import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/firebase_options.dart';
import 'package:ticketchain/pages/main_page.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';

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
      getPages: [
        GetPage(name: '/', page: () => const MainPage()),
      ],
      home: const MainPage(),
      theme: ThemeData(
        useMaterial3: true,
        shadowColor: TicketchainColor.black,
        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(
            iconColor: MaterialStatePropertyAll(TicketchainColor.purple),
            iconSize: MaterialStatePropertyAll(48),
          ),
        ),
        // elevatedButtonTheme: const ElevatedButtonThemeData(
        //   style: ButtonStyle(
        //     backgroundColor: MaterialStatePropertyAll(TicketchainColor.white),
        //     surfaceTintColor: MaterialStatePropertyAll(TicketchainColor.transparent),
        //     elevation: MaterialStatePropertyAll(8),
        //     padding: MaterialStatePropertyAll(EdgeInsets.all(24)),
        //     shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
        //   ),
        // ),
        cardTheme: const CardTheme(
          elevation: 8,
          color: TicketchainColor.white,
          surfaceTintColor: TicketchainColor.transparent,
          shadowColor: TicketchainColor.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: TicketchainColor.purple,
          contentPadding: EdgeInsets.all(16),
          titleTextStyle: TicketchainTextStyle.title,
          subtitleTextStyle: TicketchainTextStyle.subtitle,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
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
      ),
    );
  }
}
