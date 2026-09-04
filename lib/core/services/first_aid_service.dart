import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/first_aid.dart';

class FirstAidService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'first_aid';

  Future<void> addFirstAid(FirstAid firstAid) async {
    await _firestore.collection(_collection).add(firstAid.toMap());
  }

  Future<List<FirstAid>> getFirstAids() async {
    final snapshot = await _firestore.collection(_collection).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => FirstAid.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> updateFirstAid(FirstAid firstAid) async {
    await _firestore.collection(_collection).doc(firstAid.id).update(firstAid.toMap());
  }

  Future<void> deleteFirstAid(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
