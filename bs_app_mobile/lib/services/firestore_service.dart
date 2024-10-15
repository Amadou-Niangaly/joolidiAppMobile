import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Ajout d'un document
  Future<void> addDocument(String collectionPath, Map<String, dynamic> data) async {
    await _db.collection(collectionPath).add(data);
  }

  // Récupération de tous les documents d'une collection
  Stream<List<Map<String, dynamic>>> getDocuments(String collectionPath) {
    return _db.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  // Récupération d'un document par ID
  Future<Map<String, dynamic>?> getDocumentById(String collectionPath, String id) async {
    DocumentSnapshot doc = await _db.collection(collectionPath).doc(id).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // Mise à jour d'un document
  Future<void> updateDocument(String collectionPath, String id, Map<String, dynamic> data) async {
    await _db.collection(collectionPath).doc(id).update(data);
  }

  // Suppression d'un document
  Future<void> deleteDocument(String collectionPath, String id) async {
    await _db.collection(collectionPath).doc(id).delete();
  }
}
