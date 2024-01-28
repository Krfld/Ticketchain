import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ticketchain/models/event_model.dart';
import 'package:ticketchain/models/package_model.dart';
import 'package:ticketchain/models/ticket_model.dart';
import 'package:ticketchain/models/user_model.dart';
import 'package:ticketchain/services/authentication_service.dart';
import 'package:ticketchain/services/firestore_service.dart';

class TicketchainService extends GetxService {
  final authenticationService = Get.put(AuthenticationService());
  final firestoreService = Get.put(FirestoreService());

  UserModel get user => authenticationService.user;

  Future<List<EventModel>> getEvents() async {
    List<QueryDocumentSnapshot> docs =
        await firestoreService.getCollection('events');
    return docs
        .map((e) => EventModel.fromDoc(e.id, e.data() as Map<String, dynamic>))
        .toList()
      ..sort();
  }

  Future<List<TicketModel>> getTickets() async {
    List<TicketModel> tickets = [];
    List<QueryDocumentSnapshot> docs =
        await firestoreService.getCollection('users/${user.id}/tickets');
    for (QueryDocumentSnapshot doc in docs) {
      DocumentSnapshot eventDoc =
          await ((doc.data()! as Map)['event'] as DocumentReference).get();
      EventModel event = EventModel.fromDoc(
          eventDoc.id, eventDoc.data()! as Map<String, dynamic>);
      PackageModel package = event.packages[(doc.data()! as Map)['package']];
      tickets.add(TicketModel(event, package, (doc.data()! as Map)['amount']));
    }
    return tickets;
  }

  Future<void> buyTickets(PackageModel package, int amount) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot collection = await firestore
        .collection('users/${user.id}/tickets')
        .where('event', isEqualTo: firestore.doc('events/${package.eventId}'))
        .where('package', isEqualTo: package.id)
        .get();

    if (collection.docs.isNotEmpty) {
      await collection.docs.single.reference
          .update({'amount': FieldValue.increment(amount)});
    } else {
      await firestore.collection('users/${user.id}/tickets').add({
        'event': firestore.doc('events/${package.eventId}'),
        'package': package.id,
        'amount': amount,
      });
    }
  }
}
