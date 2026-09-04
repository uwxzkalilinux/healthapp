import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/constants/cloudinary_constants.dart';
import 'dart:developer';

class TestBackendPage extends StatefulWidget {
  const TestBackendPage({super.key});

  @override
  State<TestBackendPage> createState() => _TestBackendPageState();
}

class _TestBackendPageState extends State<TestBackendPage> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  String _status = 'جاهز للاختبار';
  String? _testImageUrl;

  void _updateStatus(String status) {
    setState(() => _status = status);
    log('💡 $status');
  }

  // 1. اختبار رفع صورة لـ Cloudinary
  Future<void> _testCloudinaryUpload() async {
    _updateStatus('جاري اختيار الصورة...');
    try {
      final result = await _cloudinaryService.pickAndUpload(
        folder: CloudinaryConstants.medicineFolderPath,
        onProgress: (p) => _updateStatus('جاري الرفع: ${(p * 100).toInt()}%'),
      );
      
      setState(() => _testImageUrl = result.secureUrl);
      _updateStatus('✅ نجح الرفع! الرابط: ${result.secureUrl}');
    } catch (e) {
      _updateStatus('❌ فشل الرفع: $e');
    }
  }

  // 2. اختبار الإضافة في Firestore
  Future<void> _testFirestoreWrite() async {
    _updateStatus('جاري حفظ البيانات في Firestore...');
    try {
      final testData = {
        'name': {'ar': 'دواء تجريبي', 'en': 'Test Medicine'},
        'category': {'ar': 'مسكنات', 'en': 'Painkillers'},
        'imageURL': _testImageUrl ?? 'لا توجد صورة',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await FirebaseFirestore.instance.collection('medicines').add(testData);
      _updateStatus('✅ تم الحفظ بنجاح! ID: ${docRef.id}');
    } catch (e) {
      _updateStatus('❌ فشل الحفظ: $e');
    }
  }

  // 3. اختبار القراءة من Firestore
  Future<void> _testFirestoreRead() async {
    _updateStatus('جاري جلب البيانات...');
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('medicines').get();
      _updateStatus('✅ تم جلب ${querySnapshot.docs.length} أدوية.');
      for (var doc in querySnapshot.docs) {
        log('💊 دواء: ${doc.data()['name']['ar']} | ID: ${doc.id}');
      }
    } catch (e) {
      _updateStatus('❌ فشل الجلب: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختبار الباكيند 🛠️')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,
              child: Text(_status, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (_testImageUrl != null) ...[
              const SizedBox(height: 10),
              Image.network(_testImageUrl!, height: 150),
            ],
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: const Text('1. اختبار Cloudinary (رفع صورة)'),
              onPressed: _testCloudinaryUpload,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('2. اختبار Firestore (إضافة دواء)'),
              onPressed: _testFirestoreWrite,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('3. اختبار Firestore (قراءة البيانات)'),
              onPressed: _testFirestoreRead,
            ),
          ],
        ),
      ),
    );
  }
}
