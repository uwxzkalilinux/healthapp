import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/health_tip.dart';
import '../../../../core/services/health_tip_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../favorites/cubit/favorites_cubit.dart';
import '../../../admin/presentation/pages/add_health_tip_page.dart';

class HealthTipDetailsScreen extends StatelessWidget {
  final HealthTip healthTip;
  const HealthTipDetailsScreen({super.key, required this.healthTip});

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
        await HealthTipService().deleteHealthTip(healthTip.id);
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
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.green,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(healthTip.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, textBaseline: TextBaseline.alphabetic, fontSize: 16)),
                background: healthTip.imageUrl.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(healthTip.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, size: 100, color: Colors.white)),
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
                    : const Center(child: Icon(Icons.eco, size: 100, color: Colors.white)),
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
                              final isFav = favorites.contains(healthTip.id);
                              return IconButton(
                                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? AppTheme.alertRed : Colors.white),
                                onPressed: () {
                                  context.read<UserService>().toggleFavorite(userId, healthTip.id);
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
                                    MaterialPageRoute(builder: (_) => AddHealthTipPage(tipToEdit: healthTip)),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                      child: Text(healthTip.category, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      healthTip.content,
                      style: const TextStyle(fontSize: 18, height: 1.8, color: Colors.black87),
                    ),
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
}
