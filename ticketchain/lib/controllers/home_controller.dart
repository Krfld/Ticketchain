import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/event_model.dart';
import 'package:ticketchain/services/ticketchain_service.dart';

class HomeController extends GetxController {
  @override
  void onInit() async {
    await getEvents();
    super.onInit();
  }

  final ticketchainService = Get.put(TicketchainService());

  final searchController = TextEditingController();
  final RxString filter = RxString('');
  final RxList<EventModel> _events = RxList();
  List<EventModel> get events => _events.where((event) => event.name.toLowerCase().contains(filter().toLowerCase())).toList();

  Future<void> getEvents() async {
    _events(await ticketchainService.getEvents());
  }

  void clearFilter() {
    searchController.clear();
    filter.value = '';
  }
}
