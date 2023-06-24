import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/event_model.dart';

class HomeController extends GetxController {
  @override
  void onInit() async {
    await getEvents();
    super.onInit();
  }

  final searchController = TextEditingController();

  List<EventModel> _events = [];
  RxList<EventModel> events = RxList();

  Future<void> getEvents() async {
    //todo change to use firestore service
    await FirebaseFirestore.instance.collection('Events').get().then((QuerySnapshot querySnapshot) {
      _events = querySnapshot.docs.map((e) => EventModel.fromDoc(e.data() as Map<String, dynamic>)).toList()..sort();
      filterEvents('');
    });
  }

  void filterEvents(String filter) {
    events(_events.where((event) => event.name.toLowerCase().contains(filter.toLowerCase())).toList());
  }
}
