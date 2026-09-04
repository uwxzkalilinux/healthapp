import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/disease.dart';

class DiseaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'diseases';

  // إضافة مرض جديد
  Future<void> addDisease(Disease disease) async {
    try {
      await _firestore.collection(_collection).add(disease.toMap());
    } catch (e) {
      throw Exception('فشل في إضافة المرض: $e');
    }
  }

  // جلب كل الأمراض
  Future<List<Disease>> getDiseases() async {
    try {
      final snapshot = await _firestore.collection(_collection).orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => Disease.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('فشل في جلب الأمراض: $e');
    }
  }

  // جلب مرض واحد بواسطة الـ ID
  Future<Disease?> getDiseaseById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Disease.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('فشل في جلب المرض: $e');
    }
  }

  // تحديث مرض
  Future<void> updateDisease(Disease disease) async {
    try {
      await _firestore.collection(_collection).doc(disease.id).update(disease.toMap());
    } catch (e) {
      throw Exception('فشل في تحديث المرض: $e');
    }
  }

  // حذف مرض
  Future<void> deleteDisease(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('فشل في حذف المرض: $e');
    }
  }
}
