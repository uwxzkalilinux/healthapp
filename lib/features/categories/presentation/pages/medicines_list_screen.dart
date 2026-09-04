import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/medicine_service.dart';
import '../../../../core/models/medicine.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../admin/presentation/pages/add_medicine_page.dart';
import 'medicine_details_screen.dart';

class MedicinesListScreen extends StatefulWidget {
  const MedicinesListScreen({super.key});

  @override
  State<MedicinesListScreen> createState() => _MedicinesListScreenState();
}

class _MedicinesListScreenState extends State<MedicinesListScreen> {
  final _medicineService = MedicineService();
  late Future<List<Medicine>> _medicinesFuture;
  
  // Multi-select state
  bool _isMultiSelectMode = false;
  final Set<String> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _refreshMedicines();
  }

  void _refreshMedicines() {
    setState(() {
      _medicinesFuture = _medicineService.getMedicines();
      _isMultiSelectMode = false;
      _selectedItems.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
        if (_selectedItems.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedItems.add(id);
      }
    });
  }

  void _toggleMultiSelectMode(String id) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedItems.add(id);
    });
  }

  Future<void> _deleteSelectedItems() async {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف العناصر'),
          content: Text('هل أنت متأكد من حذف ${_selectedItems.length} عنصر؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⏳ جاري الحذف...')));
                
                try {
                  for (final id in _selectedItems) {
                    await _medicineService.deleteMedicine(id);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ تم الحذف بنجاح'), backgroundColor: AppTheme.primaryTeal),
                    );
                    _refreshMedicines();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ خطأ: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.alertRed),
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select((AuthCubit cubit) => (cubit.state is AuthAuthenticated) ? (cubit.state as AuthAuthenticated).user.isAdmin : false);

    return Scaffold(
      backgroundColor: AppTheme.mintBackground,
      appBar: AppBar(
        title: _isMultiSelectMode 
          ? Text('${_selectedItems.length} محدد', style: const TextStyle(fontWeight: FontWeight.bold))
          : const Text('الأدوية'),
        centerTitle: true,
        leading: _isMultiSelectMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isMultiSelectMode = false;
                    _selectedItems.clear();
                  });
                },
              )
            : null,
        actions: [
          if (_isMultiSelectMode && isAdmin)
            IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.alertRed),
              onPressed: _deleteSelectedItems,
            ),
        ],
      ),
      body: FutureBuilder<List<Medicine>>(
        future: _medicinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد أدوية مضافة حالياً.'));
          }

          final medicines = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshMedicines(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicines[index];
                final isSelected = _selectedItems.contains(medicine.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: medicine.imageUrl.isNotEmpty
                            ? Image.network(
                                medicine.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.medication, size: 30, color: AppTheme.primaryTeal),
                              )
                            : const Icon(Icons.medication, size: 30, color: AppTheme.primaryTeal),
                      ),
                    ),
                    title: Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(medicine.scientificName, style: const TextStyle(color: Colors.grey)),
                    trailing: _isMultiSelectMode && isAdmin
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (value) => _toggleSelection(medicine.id),
                            activeColor: AppTheme.primaryTeal,
                          )
                        : const Icon(Icons.arrow_forward_ios, size: 16),
                    onLongPress: isAdmin && !_isMultiSelectMode
                        ? () => _toggleMultiSelectMode(medicine.id)
                        : null,
                    onTap: () async {
                      if (_isMultiSelectMode && isAdmin) {
                        _toggleSelection(medicine.id);
                        return;
                      }
                      
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MedicineDetailsScreen(medicine: medicine)),
                      );
                      if (result == true) {
                        _refreshMedicines();
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isAdmin && !_isMultiSelectMode
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddMedicinePage()),
                );
                _refreshMedicines();
              },
              backgroundColor: AppTheme.primaryTeal,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
