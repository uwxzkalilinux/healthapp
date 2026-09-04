import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/health_tip.dart';
import '../../../../core/services/health_tip_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:typed_data';
import '../../../../core/constants/cloudinary_constants.dart';

class AddHealthTipPage extends StatefulWidget {
  final HealthTip? tipToEdit;
  const AddHealthTipPage({super.key, this.tipToEdit});

  @override
  State<AddHealthTipPage> createState() => _AddHealthTipPageState();
}

class _AddHealthTipPageState extends State<AddHealthTipPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String _selectedCategory = 'عامة';
  final List<String> _categories = ['عامة', 'الوقاية', 'صحة نفسية', 'أطفال', 'كبار السن', 'عادات صحية'];

  bool _isLoading = false;
  String _imageUrl = '';
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.tipToEdit != null) {
      _titleController.text = widget.tipToEdit!.title;
      _contentController.text = widget.tipToEdit!.content;
      _imageUrl = widget.tipToEdit!.imageUrl;
      if (_categories.contains(widget.tipToEdit!.category)) {
        _selectedCategory = widget.tipToEdit!.category;
      } else {
        _selectedCategory = _categories.first;
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

      final tip = HealthTip(
        id: widget.tipToEdit?.id ?? '',
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        imageUrl: imageUrl,
        createdAt: widget.tipToEdit?.createdAt ?? DateTime.now(),
      );

      if (widget.tipToEdit == null) {
        await HealthTipService().addHealthTip(tip);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة بنجاح')));
      } else {
        await HealthTipService().updateHealthTip(tip);
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
    final isEdit = widget.tipToEdit != null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.mintBackground,
        appBar: AppBar(
          title: Text(isEdit ? 'تعديل النصيحة' : 'إضافة نصيحة صحية'),
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
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(_imageBytes!, fit: BoxFit.cover))
                      : _imageUrl.isNotEmpty
                          ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(_imageUrl, fit: BoxFit.cover))
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 40, color: Colors.green),
                                SizedBox(height: 8),
                                Text('إضافة صورة', style: TextStyle(color: Colors.green)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(_titleController, 'عنوان النصيحة'),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'التصنيف',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),

              _buildTextField(_contentController, 'محتوى النصيحة', maxLines: 6),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
