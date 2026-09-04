import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/disease.dart';
import '../../../../core/services/disease_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../admin/presentation/pages/add_disease_page.dart';
import '../../../favorites/cubit/favorites_cubit.dart';

class DiseaseDetailsScreen extends StatelessWidget {
  final Disease disease;

  const DiseaseDetailsScreen({super.key, required this.disease});

  Future<void> _deleteDisease(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المرض'),
        content: const Text('هل أنت متأكد من حذف هذا المرض؟'),
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
        await DiseaseService().deleteDisease(disease.id);
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
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: AppTheme.mintBackground,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  backgroundColor: AppTheme.primaryTeal,
                  flexibleSpace: FlexibleSpaceBar(
                    background: disease.imageUrl.isNotEmpty
                        ? Image.network(
                            disease.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.coronavirus_outlined, size: 80, color: Colors.white),
                          )
                        : const Icon(Icons.coronavirus_outlined, size: 80, color: Colors.white),
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
                                  final isFav = favorites.contains(disease.id);
                                  return IconButton(
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? AppTheme.alertRed : Colors.white,
                                    ),
                                    onPressed: () {
                                      context.read<UserService>().toggleFavorite(userId, disease.id);
                                    },
                                  );
                                },
                              ),
                              if (state.user.isAdmin)
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'delete') {
                                      _deleteDisease(context);
                                    } else if (value == 'edit') {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => AddDiseasePage(diseaseToEdit: disease)),
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
                  bottom: const TabBar(
                    indicatorColor: Colors.white,
                    indicatorWeight: 4,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    tabs: [
                      Tab(text: 'الأعراض'),
                      Tab(text: 'الأسباب'),
                      Tab(text: 'العلاج'),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          disease.name,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          disease.scientificName,
                          style: const TextStyle(fontSize: 18, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                        if (disease.description.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
                            ),
                            child: Text(disease.description, style: const TextStyle(fontSize: 16, height: 1.5, color: AppTheme.textSecondary)),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                _buildTabContent(disease.symptoms, emptyMessage: 'لا توجد أعراض مضافة.'),
                _buildTabContent(disease.causes, emptyMessage: 'لا توجد أسباب مضافة.'),
                _buildTabContent(disease.treatment, emptyMessage: 'لا توجد طرق علاج مضافة.'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(List<String> items, {required String emptyMessage}) {
    if (items.isEmpty) {
      return Center(child: Text(emptyMessage, style: const TextStyle(color: Colors.grey, fontSize: 16)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 14, color: AppTheme.primaryTeal),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(items[index], style: const TextStyle(fontSize: 16, height: 1.5, color: AppTheme.textPrimary))),
            ],
          ),
        );
      },
    );
  }
}
