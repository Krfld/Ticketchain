import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/event_model.dart';
import 'package:ticketchain/services/firestore_service.dart';

class HomeController extends GetxController {
  @override
  void onInit() async {
    await getEvents();
    super.onInit();
  }

  final firestoreService = Get.put(FirestoreService());

  final TextEditingController searchController = TextEditingController();
  final RxString filter = RxString('');

  final RxList<EventModel> _events = RxList();
  List<EventModel> get events => _events.where((event) => event.name.toLowerCase().contains(filter().toLowerCase())).toList();

  Future<void> getEvents() async {
    _events.clear();
    await firestoreService.getCollection('events').then((List<QueryDocumentSnapshot> docs) => _events(docs.map((e) => EventModel.fromDoc(e.id, e.data() as Map<String, dynamic>)).toList()..sort()));
  }
}
