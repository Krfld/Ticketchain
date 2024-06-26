import 'package:flutter/material.dart';
import 'package:ticketchain/theme/ticketchain_color.dart';
import 'package:ticketchain/theme/ticketchain_text_style.dart';

final ticketchainTheme = ThemeData(
  useMaterial3: true,
  shadowColor: TicketchainColor.black,
  // iconTheme: const IconThemeData(
  //   color: TicketchainColor.purple,
  // ),
  iconButtonTheme: const IconButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(TicketchainColor.white),
      iconColor: WidgetStatePropertyAll(TicketchainColor.purple),
      iconSize: WidgetStatePropertyAll(48),
    ),
  ),
  textButtonTheme: const TextButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(TicketchainColor.transparent),
      foregroundColor: WidgetStatePropertyAll(TicketchainColor.white),
      surfaceTintColor: WidgetStatePropertyAll(TicketchainColor.transparent),
      textStyle: WidgetStatePropertyAll(TicketchainTextStyle.textBold),
      iconSize: WidgetStatePropertyAll(20),
    ),
  ),
  elevatedButtonTheme: const ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(TicketchainColor.purple),
      foregroundColor: WidgetStatePropertyAll(TicketchainColor.white),
      surfaceTintColor: WidgetStatePropertyAll(TicketchainColor.transparent),
      elevation: WidgetStatePropertyAll(8),
      padding: WidgetStatePropertyAll(EdgeInsets.all(20)),
      textStyle: WidgetStatePropertyAll(TicketchainTextStyle.title),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)))),
    ),
  ),
  cardTheme: const CardTheme(
    elevation: 8,
    color: TicketchainColor.white,
    surfaceTintColor: TicketchainColor.transparent,
    shadowColor: TicketchainColor.black,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: TicketchainColor.purple,
    contentPadding: EdgeInsets.all(16),
    titleTextStyle: TicketchainTextStyle.title,
    subtitleTextStyle: TicketchainTextStyle.subtitle,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    prefixIconColor: TicketchainColor.purple,
    contentPadding: EdgeInsets.all(20),
    hintStyle: TicketchainTextStyle.subtitle,
    border: InputBorder.none,
  ),
  dialogTheme: const DialogTheme(
    backgroundColor: TicketchainColor.white,
    surfaceTintColor: TicketchainColor.transparent,
    titleTextStyle: TicketchainTextStyle.title,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: TicketchainColor.white,
    surfaceTintColor: TicketchainColor.transparent,
    shadowColor: TicketchainColor.black,
    showDragHandle: true,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50))),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: TicketchainColor.white,
    foregroundColor: TicketchainColor.purple,
    iconSize: 48,
    elevation: 8,
    sizeConstraints: BoxConstraints.tight(const Size.square(75)),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(75))),
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: TicketchainColor.white,
    surfaceTintColor: TicketchainColor.transparent,
    shadowColor: TicketchainColor.black,
    elevation: 8,
    padding: EdgeInsets.zero,
  ),
);
