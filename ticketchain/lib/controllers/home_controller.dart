import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/event.dart';
import 'package:ticketchain/services/event_service.dart';
import 'package:ticketchain/services/ticketchain_service.dart';

class HomeController extends GetxController {
  @override
  void onInit() async {
    await getEvents();
    super.onInit();
  }

  final searchController = TextEditingController();
  final RxString filter = RxString('');
  final RxList<EventModel> _events = RxList();
  List<EventModel> get events => _events
      .where(
          (event) => event.name.toLowerCase().contains(filter().toLowerCase()))
      .toList();

  Future<void> getEvents() async {
    List<EventModel> events = [];
    List<String> eventsAddress = await TicketchainService.to.getEventsAddress();
    for (String eventAddress in eventsAddress) {
      events.add(await EventService.to.getEvent(eventAddress));
    }
    _events.assignAll(events);
  }

  void clearFilter() {
    searchController.clear();
    filter.value = '';
  }
}
