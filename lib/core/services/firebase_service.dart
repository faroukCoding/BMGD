import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createDocument(String collection, Map<String, dynamic> data) async {
    await _firestore.collection(collection).add(data);
  }

  Future<void> updateDocument(String collection, String id, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(id).update(data);
  }

  Future<void> deleteDocument(String collection, String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  Stream<QuerySnapshot> getStream(String collection, {Map<String, dynamic>? filters}) {
    Query query = _firestore.collection(collection);
    
    if (filters != null) {
      filters.forEach((key, value) {
        query = query.where(key, isEqualTo: value);
      });
    }
    
    return query.snapshots();
  }

  Future<DocumentSnapshot> getDocument(String collection, String id) async {
    return await _firestore.collection(collection).doc(id).get();
  }

  Future<List<QueryDocumentSnapshot>> getDocuments(
    String collection, {
    Map<String, dynamic>? filters,
  }) async {
    Query query = _firestore.collection(collection);
    
    if (filters != null) {
      filters.forEach((key, value) {
        query = query.where(key, isEqualTo: value);
      });
    }
    
    final snapshot = await query.get();
    return snapshot.docs;
  }
}