import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/disease_service.dart';
import '../../../../core/models/disease.dart';

class AddDiseasePage extends StatefulWidget {
  final Disease? diseaseToEdit;
  const AddDiseasePage({super.key, this.diseaseToEdit});

  @override
  State<AddDiseasePage> createState() => _AddDiseasePageState();
}

class _AddDiseasePageState extends State<AddDiseasePage> {
  final _formKey = GlobalKey<FormState>();
  final _cloudinaryService = CloudinaryService();
  final _diseaseService = DiseaseService();

  final _nameController = TextEditingController();
  final _scientificNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _causesController = TextEditingController();
  final _treatmentController = TextEditingController();
  
  XFile? _selectedImage;
  String? _imagePreviewUrl; 
  bool _isLoading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.diseaseToEdit != null) {
      final d = widget.diseaseToEdit!;
      _nameController.text = d.name;
      _scientificNameController.text = d.scientificName;
      _descriptionController.text = d.description;
      _symptomsController.text = d.symptoms.join('\n');
      _causesController.text = d.causes.join('\n');
      _treatmentController.text = d.treatment.join('\n');
      if (d.imageUrl.isNotEmpty) {
        _imagePreviewUrl = d.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scientificNameController.dispose();
    _descriptionController.dispose();
    _symptomsController.dispose();
    _causesController.dispose();
    _treatmentController.dispose();
    _cloudinaryService.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _cloudinaryService.pickImageFromGallery();
      setState(() {
        _selectedImage = image;
        _imagePreviewUrl = image.path;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.alertRed),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedImage == null && widget.diseaseToEdit == null && (_imagePreviewUrl == null || _imagePreviewUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار صورة للمرض'), backgroundColor: AppTheme.alertRed),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0.0;
    });

    try {
      String imageUrl = _imagePreviewUrl ?? '';
      
      if (_selectedImage != null) {
        final uploadResult = await _cloudinaryService.uploadImage(
          imageFile: _selectedImage!,
          folder: 'diseases',
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
            });
          },
        );
        imageUrl = uploadResult.secureUrl;
      }

      final disease = Disease(
        id: widget.diseaseToEdit?.id ?? '',
        name: _nameController.text.trim(),
        scientificName: _scientificNameController.text.trim(),
        description: _descriptionController.text.trim(),
        symptoms: _symptomsController.text.trim().split('\n').where((s) => s.isNotEmpty).toList(),
        causes: _causesController.text.trim().split('\n').where((s) => s.isNotEmpty).toList(),
        treatment: _treatmentController.text.trim().split('\n').where((s) => s.isNotEmpty).toList(),
        imageUrl: imageUrl,
        createdAt: widget.diseaseToEdit?.createdAt ?? DateTime.now(),
      );

      if (widget.diseaseToEdit != null) {
        await _diseaseService.updateDisease(disease);
      } else {
        await _diseaseService.addDisease(disease);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.diseaseToEdit != null ? '✅ تم تعديل المرض بنجاح!' : '✅ تم إضافة المرض بنجاح!'),
          backgroundColor: AppTheme.primaryTeal,
        ),
      );
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الإضافة: $e'), backgroundColor: AppTheme.alertRed),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.mintBackground,
        appBar: AppBar(
          title: Text(widget.diseaseToEdit != null ? 'تعديل المرض' : 'إضافة مرض جديد'),
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppTheme.primaryTeal),
                    const SizedBox(height: 16),
                    Text(
                      'جاري الرفع... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3), width: 2),
                          ),
                          child: _imagePreviewUrl == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 50, color: AppTheme.primaryTeal.withOpacity(0.5)),
                                    const SizedBox(height: 8),
                                    const Text('اضغط لاختيار صورة للمرض', style: TextStyle(color: AppTheme.textSecondary)),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.network(
                                    _imagePreviewUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: Icon(Icons.check_circle, size: 50, color: AppTheme.primaryTeal),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildTextField(controller: _nameController, label: 'اسم المرض', icon: Icons.coronavirus_outlined),
                      _buildTextField(controller: _scientificNameController, label: 'الاسم العلمي', icon: Icons.science_outlined),
                      _buildTextField(controller: _descriptionController, label: 'وصف المرض', icon: Icons.description_outlined, maxLines: 3),
                      _buildTextField(controller: _symptomsController, label: 'الأعراض (كل عرض في سطر)', icon: Icons.warning_amber_outlined, maxLines: 3),
                      _buildTextField(controller: _causesController, label: 'الأسباب (كل سبب في سطر)', icon: Icons.search, maxLines: 3),
                      _buildTextField(controller: _treatmentController, label: 'العلاج (كل خطوة في سطر)', icon: Icons.healing, maxLines: 3),
                      const SizedBox(height: 32),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _submitForm,
                          icon: const Icon(Icons.save),
                          label: Text(widget.diseaseToEdit != null ? 'حفظ التعديلات' : 'حفظ وإضافة المرض'),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryTeal),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'هذا الحقل مطلوب';
          }
          return null;
        },
      ),
    );
  }
}
