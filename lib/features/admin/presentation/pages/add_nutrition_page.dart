import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/nutrition.dart';
import '../../../../core/services/nutrition_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:typed_data';
import '../../../../core/constants/cloudinary_constants.dart';

class AddNutritionPage extends StatefulWidget {
  final Nutrition? nutritionToEdit;
  const AddNutritionPage({super.key, this.nutritionToEdit});

  @override
  State<AddNutritionPage> createState() => _AddNutritionPageState();
}

class _AddNutritionPageState extends State<AddNutritionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _caloriesController = TextEditingController();
  
  List<TextEditingController> _benefitControllers = [TextEditingController()];
  
  bool _isLoading = false;
  String _imageUrl = '';
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.nutritionToEdit != null) {
      _titleController.text = widget.nutritionToEdit!.title;
      _descController.text = widget.nutritionToEdit!.description;
      _caloriesController.text = widget.nutritionToEdit!.calories;
      _imageUrl = widget.nutritionToEdit!.imageUrl;
      
      if (widget.nutritionToEdit!.benefits.isNotEmpty) {
        _benefitControllers = widget.nutritionToEdit!.benefits
            .map((b) => TextEditingController(text: b))
            .toList();
      }
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

      final benefits = _benefitControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final nutrition = Nutrition(
        id: widget.nutritionToEdit?.id ?? '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        calories: _caloriesController.text.trim(),
        benefits: benefits,
        imageUrl: imageUrl,
        createdAt: widget.nutritionToEdit?.createdAt ?? DateTime.now(),
      );

      if (widget.nutritionToEdit == null) {
        await NutritionService().addNutrition(nutrition);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة بنجاح')));
      } else {
        await NutritionService().updateNutrition(nutrition);
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
    final isEdit = widget.nutritionToEdit != null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.mintBackground,
        appBar: AppBar(
          title: Text(isEdit ? 'تعديل النظام الغذائي' : 'إضافة نظام غذائي'),
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
                    border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.5)),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(_imageBytes!, fit: BoxFit.cover))
                      : _imageUrl.isNotEmpty
                          ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(_imageUrl, fit: BoxFit.cover))
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 40, color: AppTheme.primaryTeal),
                                SizedBox(height: 8),
                                Text('إضافة صورة', style: TextStyle(color: AppTheme.primaryTeal)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(_titleController, 'اسم النظام / المادة الغذائية'),
              _buildTextField(_descController, 'الوصف العام', maxLines: 3),
              _buildTextField(_caloriesController, 'السعرات الحرارية والقيم الغذائية', maxLines: 2),
              
              const SizedBox(height: 16),
              const Text('الفوائد:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ..._benefitControllers.asMap().entries.map((entry) {
                int idx = entry.key;
                var controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(child: _buildTextField(controller, 'فائدة ${idx + 1}')),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: AppTheme.alertRed),
                        onPressed: () {
                          if (_benefitControllers.length > 1) {
                            setState(() => _benefitControllers.removeAt(idx));
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () => setState(() => _benefitControllers.add(TextEditingController())),
                icon: const Icon(Icons.add, color: AppTheme.primaryTeal),
                label: const Text('إضافة فائدة أخرى', style: TextStyle(color: AppTheme.primaryTeal)),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
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

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
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
        validator: (value) => value!.isEmpty ? 'هذا الحقل مطلوب' : null,
      ),
    );
  }
}
