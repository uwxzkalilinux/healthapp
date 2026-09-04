import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/medicine_service.dart';
import '../../../../core/models/medicine.dart';

class AddMedicinePage extends StatefulWidget {
  final Medicine? medicineToEdit;
  const AddMedicinePage({super.key, this.medicineToEdit});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final _cloudinaryService = CloudinaryService();
  final _medicineService = MedicineService();

  final _nameController = TextEditingController();
  final _scientificNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _usesController = TextEditingController();
  final _dosageController = TextEditingController();
  final _sideEffectsController = TextEditingController();
  final _warningsController = TextEditingController();
  
  XFile? _selectedImage;
  String? _imagePreviewUrl;
  bool _isLoading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.medicineToEdit != null) {
      final m = widget.medicineToEdit!;
      _nameController.text = m.name;
      _scientificNameController.text = m.scientificName;
      _descriptionController.text = m.description;
      _usesController.text = m.uses.join('\n');
      _dosageController.text = m.dosage;
      _sideEffectsController.text = m.sideEffects.join('\n');
      _warningsController.text = m.warnings.join('\n');
      if (m.imageUrl.isNotEmpty) {
        _imagePreviewUrl = m.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scientificNameController.dispose();
    _descriptionController.dispose();
    _usesController.dispose();
    _dosageController.dispose();
    _sideEffectsController.dispose();
    _warningsController.dispose();
    _cloudinaryService.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _cloudinaryService.pickImageFromGallery();
      // للويب: نستخدم readAsBytes لعرض الصورة المحددة مؤقتاً
      setState(() {
        _selectedImage = image;
        _imagePreviewUrl = image.path; // في الويب هذا يكون blob URL
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
    
    if (_selectedImage == null && widget.medicineToEdit == null && (_imagePreviewUrl == null || _imagePreviewUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار صورة للدواء'), backgroundColor: AppTheme.alertRed),
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
          folder: 'medicines',
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
            });
          },
        );
        imageUrl = uploadResult.secureUrl;
      }

      final medicine = Medicine(
        id: widget.medicineToEdit?.id ?? '',
        name: _nameController.text.trim(),
        scientificName: _scientificNameController.text.trim(),
        description: _descriptionController.text.trim(),
        uses: _usesController.text.trim().split('\n').where((s) => s.isNotEmpty).toList(),
        dosage: _dosageController.text.trim(),
        sideEffects: _sideEffectsController.text.trim().split('\n').where((s) => s.isNotEmpty).toList(),
        warnings: _warningsController.text.trim().split('\n').where((s) => s.isNotEmpty).toList(),
        imageUrl: imageUrl,
        createdAt: widget.medicineToEdit?.createdAt ?? DateTime.now(),
      );

      if (widget.medicineToEdit != null) {
        await _medicineService.updateMedicine(medicine);
      } else {
        await _medicineService.addMedicine(medicine);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.medicineToEdit != null ? '✅ تم تعديل الدواء بنجاح!' : '✅ تم إضافة الدواء بنجاح!'),
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
          title: Text(widget.medicineToEdit != null ? 'تعديل الدواء' : 'إضافة دواء جديد'),
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
                      // قسم اختيار الصورة
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
                                    const Text('اضغط لاختيار صورة الدواء', style: TextStyle(color: AppTheme.textSecondary)),
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

                      _buildTextField(controller: _nameController, label: 'الاسم التجاري (مثال: بنادول إكسترا)', icon: Icons.medication),
                      _buildTextField(controller: _scientificNameController, label: 'الاسم العلمي (مثال: Paracetamol)', icon: Icons.science_outlined),
                      _buildTextField(controller: _descriptionController, label: 'وصف الدواء', icon: Icons.description_outlined, maxLines: 3),
                      _buildTextField(controller: _usesController, label: 'دواعي الاستعمال (كل استخدام في سطر)', icon: Icons.healing_outlined, maxLines: 3),
                      _buildTextField(controller: _dosageController, label: 'الجرعة وطريقة الاستخدام', icon: Icons.timer_outlined, maxLines: 2),
                      _buildTextField(controller: _sideEffectsController, label: 'الآثار الجانبية (كل أثر في سطر)', icon: Icons.warning_amber_outlined, maxLines: 3),
                      _buildTextField(controller: _warningsController, label: 'تحذيرات وموانع الاستخدام (كل تحذير في سطر)', icon: Icons.report_problem_outlined, maxLines: 3),
                      const SizedBox(height: 32),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _submitForm,
                          icon: const Icon(Icons.save),
                          label: Text(widget.medicineToEdit != null ? 'حفظ التعديلات' : 'حفظ وإضافة الدواء'),
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
