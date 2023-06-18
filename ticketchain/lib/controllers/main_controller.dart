import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/event_model.dart';
import 'package:ticketchain/tabs/home_tab.dart';
import 'package:ticketchain/tabs/profile_tab.dart';

class MainController extends GetxController {
  @override
  void onInit() async {
    await _getDummyEvents();
    super.onInit();
  }

  final List tabs = [
    const HomeTab(),
    const ProfileTab()
  ];

  RxList<EventModel> events = RxList();

  Future<void> _getDummyEvents() async {
    String eventsJson = await rootBundle.loadString('assets/dummy/events.json');
    List eventsList = jsonDecode(eventsJson);
    events(eventsList.map((e) => EventModel.fromJson(e)).toList()..sort());
  }
}
