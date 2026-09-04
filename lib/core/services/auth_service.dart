import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService({
    auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<AppUser?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return await getUserDetails(user.uid);
  }

  Future<AppUser?> getUserDetails(String uid) async {
    try {
      final doc = await _firestore.collection('Users').doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      bool isAdmin = data['role'] == 'admin';

      // Fallback to Admins collection if role is not set
      if (!isAdmin) {
        final adminDoc = await _firestore.collection('Admins').doc(uid).get();
        isAdmin = adminDoc.exists;
      }

      return AppUser.fromMap(data, doc.id, isAdmin: isAdmin);
    } catch (e) {
      throw Exception('فشل جلب بيانات المستخدم: $e');
    }
  }

  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('لم يتم إرجاع مستخدم بعد تسجيل الدخول.');
      
      final appUser = await getUserDetails(user.uid);
      if (appUser == null) {
        throw Exception('بيانات المستخدم غير موجودة في قاعدة البيانات.');
      }
      return appUser;
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('لم يتم إنشاء حساب بنجاح.');

      final appUser = AppUser(
        uid: user.uid,
        name: name,
        email: email,
        isAdmin: false, 
      );

      await _firestore.collection('Users').doc(user.uid).set({
        ...appUser.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return appUser;
    } on auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Exception _handleAuthException(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('لا يوجد حساب مرتبط بهذا البريد الإلكتروني.');
      case 'wrong-password':
        return Exception('كلمة المرور غير صحيحة.');
      case 'email-already-in-use':
        return Exception('البريد الإلكتروني مسجل مسبقاً.');
      case 'invalid-email':
        return Exception('صيغة البريد الإلكتروني غير صالحة.');
      case 'weak-password':
        return Exception('كلمة المرور ضعيفة جداً.');
      case 'invalid-credential':
        return Exception('البيانات المدخلة غير صحيحة.');
      default:
        return Exception('حدث خطأ أثناء المصادقة: ${e.message}');
    }
  }
}
