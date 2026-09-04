import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine.dart';

class MedicineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'medicines';

  // إضافة دواء جديد
  Future<void> addMedicine(Medicine medicine) async {
    try {
      await _firestore.collection(_collection).add(medicine.toMap());
    } catch (e) {
      throw Exception('فشل في إضافة الدواء: $e');
    }
  }

  // جلب كل الأدوية
  Future<List<Medicine>> getMedicines() async {
    try {
      final snapshot = await _firestore.collection(_collection).orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => Medicine.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('فشل في جلب الأدوية: $e');
    }
  }

  // جلب دواء واحد بواسطة الـ ID
  Future<Medicine?> getMedicineById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Medicine.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('فشل في جلب الدواء: $e');
    }
  }

  // تحديث دواء
  Future<void> updateMedicine(Medicine medicine) async {
    try {
      await _firestore.collection(_collection).doc(medicine.id).update(medicine.toMap());
    } catch (e) {
      throw Exception('فشل في تحديث الدواء: $e');
    }
  }

  // حذف دواء
  Future<void> deleteMedicine(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('فشل في حذف الدواء: $e');
    }
  }
}
