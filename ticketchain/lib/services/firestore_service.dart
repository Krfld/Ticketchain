import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> getCollection(String collectionPath) async => (await _firestore.collection(collectionPath).get()).docs;

  DocumentReference getDocumentRef(String collectionPath, String documentId) => _firestore.collection(collectionPath).doc(documentId);
}
