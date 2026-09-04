import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/article_card.dart';
import '../../../categories/presentation/pages/medicines_list_screen.dart';
import '../../../categories/presentation/pages/diseases_list_screen.dart';
import '../../../categories/presentation/pages/nutrition_list_screen.dart';
import '../../../categories/presentation/pages/first_aid_list_screen.dart';
import '../../../categories/presentation/pages/medical_tests_list_screen.dart';
import '../../../categories/presentation/pages/health_tips_list_screen.dart';
import '../../../../core/models/article.dart';
import '../../../../core/services/article_service.dart';
import '../../../articles/presentation/pages/articles_list_screen.dart';
import '../../../articles/presentation/pages/article_details_screen.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../core/services/health_tip_service.dart';
import '../../../../core/models/health_tip.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _healthTipService = HealthTipService();
  HealthTip? _randomTip;

  @override
  void initState() {
    super.initState();
    _fetchRandomTip();
  }

  Future<void> _fetchRandomTip() async {
    try {
      final tips = await _healthTipService.getHealthTips();
      if (tips.isNotEmpty) {
        final random = Random();
        setState(() {
          _randomTip = tips[random.nextInt(tips.length)];
        });
      }
    } catch (e) {
      // Handle error gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mintBackground,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHealthBanner(context),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'الأقسام الرئيسية', null, null),
            const SizedBox(height: 14),
            _buildCategoriesGrid(),

            const SizedBox(height: 28),
            _buildSectionHeader(context, 'آخر المقالات', 'عرض الكل', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticlesListScreen()));
            }),
            const SizedBox(height: 14),
            _buildRecentArticles(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.mintBackground,
      elevation: 0,
      title: const Text(
        'الرئيسية',
        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.notifications_none_outlined, color: AppTheme.textPrimary),
        onPressed: () {},
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthTipsListScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2AAA8A), Color(0xFF38C9A7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _randomTip?.title ?? 'ابدأ يومك\nبخيارات صحية',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'تصفح النصائح',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String? actionText, VoidCallback? onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        if (actionText != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: AppTheme.primaryTeal.withOpacity(0.08),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionText,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.primaryTeal),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    return Builder(
      builder: (context) {
        final List<Map<String, dynamic>> categories = [
          {'title': 'الأدوية', 'icon': Icons.medication, 'page': const MedicinesListScreen(), 'color': const Color(0xFF2AAA8A)},
          {'title': 'الأمراض', 'icon': Icons.coronavirus_outlined, 'page': const DiseasesListScreen(), 'color': const Color(0xFFE67E22)},
          {'title': 'التغذية', 'icon': Icons.apple, 'page': const NutritionListScreen(), 'color': const Color(0xFF27AE60)},
          {'title': 'الإسعافات الأولية', 'icon': Icons.medical_services_outlined, 'page': const FirstAidListScreen(), 'color': const Color(0xFFE74C3C)},
          {'title': 'المختبر والفحوصات', 'icon': Icons.science_outlined, 'page': const MedicalTestsListScreen(), 'color': const Color(0xFF3498DB)},
          {'title': 'النصائح الصحية', 'icon': Icons.eco_outlined, 'page': const HealthTipsListScreen(), 'color': const Color(0xFF9B59B6)},
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (context, index) {
            return CategoryCard(
              title: categories[index]['title'] as String,
              iconPath: '',
              fallbackIcon: categories[index]['icon'] as IconData,
              iconColor: categories[index]['color'] as Color,
              bgColor: (categories[index]['color'] as Color).withOpacity(0.08),
              onTap: () {
                final page = categories[index]['page'] as Widget?;
                if (page != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRecentArticles(BuildContext context) {
    return FutureBuilder<List<Article>>(
      future: ArticleService().getArticles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('حدث خطأ: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.article_outlined, size: 50, color: Colors.grey),
                SizedBox(height: 12),
                Text('لا توجد مقالات حالياً', style: TextStyle(color: Colors.grey, fontSize: 14)),
                SizedBox(height: 4),
                Text('أضف مقالات من لوحة التحكم', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }

        final articles = snapshot.data!.take(3).toList();

        return Column(
          children: articles.map((article) {
            return ArticleCard(
              title: article.title,
              summary: article.summary,
              imageUrl: article.imageUrl,
              date: intl.DateFormat('yyyy/MM/dd').format(article.createdAt),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailsScreen(article: article)));
              },
            );
          }).toList(),
        );
      },
    );
  }
}
