import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/medical_test.dart';
import '../../../../core/services/medical_test_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../favorites/cubit/favorites_cubit.dart';
import '../../../admin/presentation/pages/add_medical_test_page.dart';

class MedicalTestDetailsScreen extends StatelessWidget {
  final MedicalTest medicalTest;
  const MedicalTestDetailsScreen({super.key, required this.medicalTest});

  void _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العنصر'),
        content: const Text('هل أنت متأكد من الحذف؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: AppTheme.alertRed))),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await MedicalTestService().deleteMedicalTest(medicalTest.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف بنجاح')));
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الحذف: $e')));
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
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.indigo,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(medicalTest.testName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, textBaseline: TextBaseline.alphabetic)),
                background: medicalTest.imageUrl.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(medicalTest.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.biotech, size: 100, color: Colors.white)),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(child: Icon(Icons.biotech, size: 100, color: Colors.white)),
              ),
              actions: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      final userId = state.user.uid;
                      return Row(
                        children: [
                          BlocBuilder<FavoritesCubit, List<String>>(
                            builder: (context, favorites) {
                              final isFav = favorites.contains(medicalTest.id);
                              return IconButton(
                                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? AppTheme.alertRed : Colors.white),
                                onPressed: () {
                                  context.read<UserService>().toggleFavorite(userId, medicalTest.id);
                                },
                              );
                            },
                          ),
                          if (state.user.isAdmin)
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  _delete(context);
                                } else if (value == 'edit') {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => AddMedicalTestPage(testToEdit: medicalTest)),
                                  );
                                  if (result == true && context.mounted) Navigator.pop(context, true);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: AppTheme.primaryTeal), SizedBox(width: 8), Text('تعديل')])),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: AppTheme.alertRed), SizedBox(width: 8), Text('حذف')])),
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('الغرض من الفحص', medicalTest.purpose, Icons.help_outline, Colors.indigo),
                    _buildSection('النسب الطبيعية (Normal Range)', medicalTest.normalRange, Icons.query_stats, Colors.green.shade700),
                    if (medicalTest.preparation.isNotEmpty)
                      _buildSection('التحضيرات اللازمة (مثل: الصيام)', medicalTest.preparation, Icons.timer_outlined, Colors.orange.shade800),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Text(content, style: const TextStyle(fontSize: 16, height: 1.6)),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
