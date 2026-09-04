import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_reminder.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'reminders';

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> addReminder(MedicineReminder reminder) async {
    if (currentUserId == null) return;
    await _firestore.collection(_collection).add(reminder.toMap());
  }

  Future<void> updateReminder(MedicineReminder reminder) async {
    await _firestore.collection(_collection).doc(reminder.id).update(reminder.toMap());
  }

  Future<void> deleteReminder(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<void> toggleReminder(String id, bool isActive) async {
    await _firestore.collection(_collection).doc(id).update({'isActive': isActive});
  }

  Stream<List<MedicineReminder>> getUserRemindersStream() {
    if (currentUserId == null) return const Stream.empty();
    
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => MedicineReminder.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
