import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_tip.dart';

class HealthTipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'health_tips';

  Future<void> addHealthTip(HealthTip healthTip) async {
    await _firestore.collection(_collection).add(healthTip.toMap());
  }

  Future<List<HealthTip>> getHealthTips() async {
    final snapshot = await _firestore.collection(_collection).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => HealthTip.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> updateHealthTip(HealthTip healthTip) async {
    await _firestore.collection(_collection).doc(healthTip.id).update(healthTip.toMap());
  }

  Future<void> deleteHealthTip(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
