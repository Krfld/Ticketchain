import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/services/event_service.dart';
import 'package:ticketchain/services/ticketchain_service.dart';

class HomeController extends GetxController {
  bool loading = false;

  final searchController = TextEditingController();
  final RxString filter = RxString('');

  final RxList<EventModel> _events = RxList();

  List<EventModel> get events => _events
      .where((event) =>
          event.eventConfig.name.toLowerCase().contains(filter().toLowerCase()))
      .toList();

  Future<void> getEvents() async {
    if (loading) return;
    loading = true;

    try {
      List<EventModel> eventsTemp = [];
      List<String> eventsAddress =
          await TicketchainService.to.getEventsAddress();

      for (String eventAddress in eventsAddress) {
        eventsTemp.add(await EventService.to.getEvent(eventAddress));
      }

      _events.assignAll(eventsTemp);
    } catch (e) {
      log('catch getEvents $e');
    }

    loading = false;
  }

  void clearFilter() {
    searchController.clear();
    filter('');
  }
}
