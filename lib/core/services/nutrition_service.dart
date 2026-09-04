import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nutrition.dart';

class NutritionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'nutrition';

  Future<void> addNutrition(Nutrition nutrition) async {
    await _firestore.collection(_collection).add(nutrition.toMap());
  }

  Future<List<Nutrition>> getNutrition() async {
    final snapshot = await _firestore.collection(_collection).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Nutrition.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> updateNutrition(Nutrition nutrition) async {
    await _firestore.collection(_collection).doc(nutrition.id).update(nutrition.toMap());
  }

  Future<void> deleteNutrition(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
