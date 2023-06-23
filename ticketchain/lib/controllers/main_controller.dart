import 'dart:convert';

import 'package:flutter/material.dart';
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

  Future<void> _getDummyEvents() async {
    String eventsJson = await rootBundle.loadString('assets/dummy/events.json');
    List eventsList = jsonDecode(eventsJson);
    _events = eventsList.map((e) => EventModel.fromJson(e)).toList()..sort();
    filterEvents('');
  }

  final List tabs = [
    const HomeTab(),
    const ProfileTab()
  ];

  final searchController = TextEditingController();

  List<EventModel> _events = [];
  RxList<EventModel> events = RxList();

  void filterEvents(String filter) {
    events(_events.where((event) => event.name.toLowerCase().contains(filter.toLowerCase())).toList());
  }
}
