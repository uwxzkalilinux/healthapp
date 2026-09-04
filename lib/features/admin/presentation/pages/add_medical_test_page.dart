import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/medical_test.dart';
import '../../../../core/services/medical_test_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:typed_data';
import '../../../../core/constants/cloudinary_constants.dart';

class AddMedicalTestPage extends StatefulWidget {
  final MedicalTest? testToEdit;
  const AddMedicalTestPage({super.key, this.testToEdit});

  @override
  State<AddMedicalTestPage> createState() => _AddMedicalTestPageState();
}

class _AddMedicalTestPageState extends State<AddMedicalTestPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _normalRangeController = TextEditingController();
  final _preparationController = TextEditingController();
  
  bool _isLoading = false;
  String _imageUrl = '';
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.testToEdit != null) {
      _nameController.text = widget.testToEdit!.testName;
      _purposeController.text = widget.testToEdit!.purpose;
      _normalRangeController.text = widget.testToEdit!.normalRange;
      _preparationController.text = widget.testToEdit!.preparation;
      _imageUrl = widget.testToEdit!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<String?> _uploadImageToCloudinary() async {
    if (_imageBytes == null) return null;

    try {
      final mimeType = lookupMimeType('', headerBytes: _imageBytes) ?? 'image/jpeg';
      final dio = Dio();
      
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          _imageBytes!,
          filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.${mimeType.split('/').last}',
          contentType: MediaType.parse(mimeType),
        ),
        'upload_preset': CloudinaryConstants.uploadPreset,
      });

      final response = await dio.post(CloudinaryConstants.uploadUrl, data: formData);

      if (response.statusCode == 200) {
        return response.data['secure_url'];
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String imageUrl = _imageUrl;
      if (_imageBytes != null) {
        final uploadedUrl = await _uploadImageToCloudinary();
        if (uploadedUrl != null) imageUrl = uploadedUrl;
      }

      final test = MedicalTest(
        id: widget.testToEdit?.id ?? '',
        testName: _nameController.text.trim(),
        purpose: _purposeController.text.trim(),
        normalRange: _normalRangeController.text.trim(),
        preparation: _preparationController.text.trim(),
        imageUrl: imageUrl,
        createdAt: widget.testToEdit?.createdAt ?? DateTime.now(),
      );

      if (widget.testToEdit == null) {
        await MedicalTestService().addMedicalTest(test);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة بنجاح')));
      } else {
        await MedicalTestService().updateMedicalTest(test);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم التعديل بنجاح')));
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.testToEdit != null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.mintBackground,
        appBar: AppBar(
          title: Text(isEdit ? 'تعديل الفحص' : 'إضافة فحص طبي'),
          backgroundColor: AppTheme.mintBackground,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.indigo.withOpacity(0.5)),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(_imageBytes!, fit: BoxFit.cover))
                      : _imageUrl.isNotEmpty
                          ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(_imageUrl, fit: BoxFit.cover))
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 40, color: Colors.indigo),
                                SizedBox(height: 8),
                                Text('إضافة صورة', style: TextStyle(color: Colors.indigo)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(_nameController, 'اسم الفحص'),
              _buildTextField(_purposeController, 'الغرض من الفحص', maxLines: 2),
              _buildTextField(_normalRangeController, 'النسبة الطبيعية (Normal Range)', maxLines: 2),
              _buildTextField(_preparationController, 'التحضيرات اللازمة (مثل: صيام 12 ساعة) (اختياري)', required: false, maxLines: 2),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEdit ? 'حفظ التعديلات' : 'إضافة', style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: required ? (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null : null,
      ),
    );
  }
}
