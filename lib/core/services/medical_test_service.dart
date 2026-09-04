import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_test.dart';

class MedicalTestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'medical_tests';

  Future<void> addMedicalTest(MedicalTest medicalTest) async {
    await _firestore.collection(_collection).add(medicalTest.toMap());
  }

  Future<List<MedicalTest>> getMedicalTests() async {
    final snapshot = await _firestore.collection(_collection).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => MedicalTest.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> updateMedicalTest(MedicalTest medicalTest) async {
    await _firestore.collection(_collection).doc(medicalTest.id).update(medicalTest.toMap());
  }

  Future<void> deleteMedicalTest(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
