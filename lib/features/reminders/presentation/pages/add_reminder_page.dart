import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/medicine_reminder.dart';
import '../../../../core/services/reminder_service.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _notesController = TextEditingController();
  
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final userId = ReminderService().currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب تسجيل الدخول أولاً.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reminder = MedicineReminder(
        id: '',
        userId: userId,
        medicineName: _medicineNameController.text.trim(),
        time: _selectedTime,
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await ReminderService().addReminder(reminder);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة التذكير بنجاح')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
        setState(() => _isLoading = false);
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
          title: const Text('إضافة تذكير جديد'),
          backgroundColor: AppTheme.mintBackground,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTextField(_medicineNameController, 'اسم الدواء (مثل: بنادول)', required: true),
              
              const SizedBox(height: 16),
              const Text('وقت التذكير', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.access_time, color: AppTheme.primaryTeal, size: 30),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildTextField(_notesController, 'ملاحظات إضافية (اختياري)', maxLines: 3, required: false),
              
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
                    : const Text('حفظ التذكير', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, bool required = false}) {
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
