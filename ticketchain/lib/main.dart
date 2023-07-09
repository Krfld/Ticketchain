import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/firebase_options.dart';
import 'package:ticketchain/pages/authentication_page.dart';
import 'package:ticketchain/pages/main_page.dart';
import 'package:ticketchain/services/authentication_service.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';
import 'package:ticketchain/widgets/ticketchain_scaffold.dart';

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
      home: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 1)),
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
            ? const TicketchainScaffold(
                body: CircularProgressIndicator(),
                scrollable: false,
              )
            : Obx(
                () => authenticationService.isAuthenticated() ? const MainPage() : const AuthenticationPage(),
              ),
      ),
      theme: ThemeData(
        useMaterial3: true,
        shadowColor: TicketchainColor.black,
        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(
            iconColor: MaterialStatePropertyAll(TicketchainColor.white),
            iconSize: MaterialStatePropertyAll(48),
          ),
        ),
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(TicketchainColor.transparent),
            foregroundColor: MaterialStatePropertyAll(TicketchainColor.white),
            surfaceTintColor: MaterialStatePropertyAll(TicketchainColor.transparent),
            textStyle: MaterialStatePropertyAll(TicketchainTextStyle.textBold),
            iconSize: MaterialStatePropertyAll(20),
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
        inputDecorationTheme: const InputDecorationTheme(
          contentPadding: EdgeInsets.all(20),
          hintStyle: TicketchainTextStyle.subtitle,
          border: InputBorder.none,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: TicketchainColor.white,
          surfaceTintColor: TicketchainColor.transparent,
          shadowColor: TicketchainColor.black,
          showDragHandle: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(50))),
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
