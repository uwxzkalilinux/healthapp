import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/nutrition.dart';
import '../../../../core/services/nutrition_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../favorites/cubit/favorites_cubit.dart';
import '../../../admin/presentation/pages/add_nutrition_page.dart';

class NutritionDetailsScreen extends StatelessWidget {
  final Nutrition nutrition;
  const NutritionDetailsScreen({super.key, required this.nutrition});

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
        await NutritionService().deleteNutrition(nutrition.id);
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
              backgroundColor: AppTheme.primaryTeal,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(nutrition.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, textBaseline: TextBaseline.alphabetic)),
                background: nutrition.imageUrl.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(nutrition.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.apple, size: 100, color: Colors.white)),
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
                    : const Center(child: Icon(Icons.apple, size: 100, color: Colors.white)),
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
                              final isFav = favorites.contains(nutrition.id);
                              return IconButton(
                                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? AppTheme.alertRed : Colors.white),
                                onPressed: () {
                                  context.read<UserService>().toggleFavorite(userId, nutrition.id);
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
                                    MaterialPageRoute(builder: (_) => AddNutritionPage(nutritionToEdit: nutrition)),
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
                    _buildSection('نظرة عامة', nutrition.description, Icons.info_outline),
                    _buildSection('السعرات الحرارية والقيم الغذائية', nutrition.calories, Icons.local_dining),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Icon(Icons.star_border, color: AppTheme.primaryTeal),
                        SizedBox(width: 8),
                        Text('أهم الفوائد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...nutrition.benefits.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle, color: AppTheme.primaryTeal, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(b, style: const TextStyle(fontSize: 16))),
                            ],
                          ),
                        )),
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

  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryTeal),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
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
