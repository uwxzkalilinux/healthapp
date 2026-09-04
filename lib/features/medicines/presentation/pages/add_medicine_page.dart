import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../image_upload/cubit/image_upload_cubit.dart';
import '../../../image_upload/widgets/image_upload_widget.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/constants/cloudinary_constants.dart';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? _uploadedImageUrl;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة دواء جديد')),
      body: BlocProvider(
        create: (_) => ImageUploadCubit(
          cloudinaryService: CloudinaryService(),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الدواء',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'أدخل اسم الدواء' : null,
              ),

              const SizedBox(height: 24),

              const Text(
                'صورة الدواء',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ImageUploadWidget(
                folder: CloudinaryConstants.medicineFolderPath,
                height: 220,
                borderRadius: 16,
                onImageUploaded: (url) {
                  setState(() {
                    _uploadedImageUrl = url;
                  });
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('حفظ الدواء', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    final medicineData = {
      'name': {
        'ar': _nameController.text,
        'en': '', 
      },
      'imageURL': _uploadedImageUrl,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('medicines')
        .add(medicineData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الدواء بنجاح')),
      );
      Navigator.pop(context);
    }
  }
}
