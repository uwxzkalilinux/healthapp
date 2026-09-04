import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/medicine.dart';
import '../../../../core/services/medicine_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../admin/presentation/pages/add_medicine_page.dart';
import '../../../favorites/cubit/favorites_cubit.dart';
import 'package:share_plus/share_plus.dart';

class MedicineDetailsScreen extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailsScreen({super.key, required this.medicine});

  Future<void> _deleteMedicine(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الدواء'),
        content: const Text('هل أنت متأكد من حذف هذا الدواء؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('حذف', style: TextStyle(color: AppTheme.alertRed)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await MedicineService().deleteMedicine(medicine.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم الحذف بنجاح'), backgroundColor: AppTheme.primaryTeal),
          );
          Navigator.pop(context, true); // إرجاع true لتحديث القائمة
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل الحذف: $e'), backgroundColor: AppTheme.alertRed),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.mintBackground,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              backgroundColor: AppTheme.primaryTeal,
              flexibleSpace: FlexibleSpaceBar(
                background: medicine.imageUrl.isNotEmpty
                    ? Image.network(
                        medicine.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.medication, size: 80, color: Colors.white),
                      )
                    : const Icon(Icons.medication, size: 80, color: Colors.white),
              ),
              actions: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      final userId = state.user.uid;
                      return Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            onPressed: () {
                              Share.share('معلومات عن دواء: ${medicine.name}\nالاسم العلمي: ${medicine.scientificName}\n\nاكتشف المزيد في تطبيق صحة+');
                            },
                          ),
                          BlocBuilder<FavoritesCubit, List<String>>(
                            builder: (context, favorites) {
                              final isFav = favorites.contains(medicine.id);
                              return IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? AppTheme.alertRed : Colors.white,
                                ),
                                onPressed: () {
                                  context.read<UserService>().toggleFavorite(userId, medicine.id);
                                },
                              );
                            },
                          ),
                          if (state.user.isAdmin)
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  _deleteMedicine(context);
                                } else if (value == 'edit') {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => AddMedicinePage(medicineToEdit: medicine)),
                                  );
                                  if (result == true && context.mounted) {
                                    Navigator.pop(context, true);
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(children: [Icon(Icons.edit, color: AppTheme.primaryTeal), SizedBox(width: 8), Text('تعديل')]),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(children: [Icon(Icons.delete, color: AppTheme.alertRed), SizedBox(width: 8), Text('حذف')]),
                                ),
                              ],
                            ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medicine.scientificName,
                      style: const TextStyle(fontSize: 18, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 24),
                    
                    if (medicine.description.isNotEmpty) ...[
                      _buildSectionTitle('الوصف'),
                      _buildContentCard(medicine.description),
                      const SizedBox(height: 16),
                    ],

                    if (medicine.dosage.isNotEmpty) ...[
                      _buildSectionTitle('الجرعة وطريقة الاستخدام'),
                      _buildContentCard(medicine.dosage),
                      const SizedBox(height: 16),
                    ],

                    if (medicine.uses.isNotEmpty) ...[
                      _buildSectionTitle('دواعي الاستعمال'),
                      _buildListCard(medicine.uses),
                      const SizedBox(height: 16),
                    ],

                    if (medicine.sideEffects.isNotEmpty) ...[
                      _buildSectionTitle('الأعراض الجانبية', color: Colors.orange),
                      _buildListCard(medicine.sideEffects),
                      const SizedBox(height: 16),
                    ],

                    if (medicine.warnings.isNotEmpty) ...[
                      _buildSectionTitle('تحذيرات وموانع الاستعمال', color: AppTheme.alertRed),
                      _buildListCard(medicine.warnings),
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Color color = AppTheme.primaryTeal}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: color),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildContentCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Text(text, style: const TextStyle(fontSize: 16, height: 1.5, color: AppTheme.textSecondary)),
    );
  }

  Widget _buildListCard(List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6.0),
                  child: Icon(Icons.circle, size: 8, color: AppTheme.primaryTeal),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 16, height: 1.5, color: AppTheme.textSecondary))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
