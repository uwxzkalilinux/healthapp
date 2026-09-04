import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> toggleFavorite(String userId, String itemId) async {
    try {
      final docRef = _firestore.collection('Users').doc(userId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        throw Exception('المستخدم غير موجود');
      }
      
      List<String> favorites = List<String>.from(doc.data()?['favorites'] ?? []);
      
      if (favorites.contains(itemId)) {
        favorites.remove(itemId);
      } else {
        favorites.add(itemId);
      }
      
      await docRef.update({'favorites': favorites});
    } catch (e) {
      throw Exception('فشل تحديث المفضلة: $e');
    }
  }

  Future<List<String>> getFavorites(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      if (!doc.exists) return [];
      return List<String>.from(doc.data()?['favorites'] ?? []);
    } catch (e) {
      throw Exception('فشل جلب المفضلة: $e');
    }
  }
}
