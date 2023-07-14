import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/event_model.dart';
import 'package:ticketchain/models/package_model.dart';
import 'package:ticketchain/models/ticket_model.dart';
import 'package:ticketchain/models/user_model.dart';
import 'package:ticketchain/services/authentication_service.dart';
import 'package:ticketchain/services/firestore_service.dart';

class ProfileController extends GetxController {
  @override
  void onInit() async {
    await getTickets();
    super.onInit();
  }

  final authenticationService = Get.put(AuthenticationService());
  final firestoreService = Get.put(FirestoreService());

  UserModel get user => authenticationService.user;

  RxList<TicketModel> tickets = RxList();

  Future getTickets() async {
    tickets.clear();
    List<QueryDocumentSnapshot> docs = await firestoreService.getCollection('users/${user.id}/tickets');
    for (QueryDocumentSnapshot doc in docs) {
      DocumentSnapshot eventDoc = await ((doc.data()! as Map)['event'] as DocumentReference).get();
      EventModel event = EventModel.fromDoc(eventDoc.id, eventDoc.data()! as Map<String, dynamic>);
      PackageModel package = event.packages[(doc.data()! as Map)['package']];
      tickets.add(TicketModel(event, package, (doc.data()! as Map)['amount']));
    }
  }
}
