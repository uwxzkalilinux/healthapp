import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/article.dart';
import '../../../../core/services/article_service.dart';
import 'article_details_screen.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../admin/presentation/pages/add_article_page.dart';
import 'package:intl/intl.dart' as intl;

class ArticlesListScreen extends StatelessWidget {
  const ArticlesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isAdmin = false;
    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        isAdmin = authState.user.isAdmin;
      }
    } catch (_) {}

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.mintBackground,
        appBar: AppBar(
          title: const Text('المقالات الطبية', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.mintBackground,
          elevation: 0,
        ),
        body: StreamBuilder<List<Article>>(
          stream: ArticleService().getArticlesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('حدث خطأ: ${snapshot.error}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            final articles = snapshot.data ?? [];

            if (articles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.article_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text('لا توجد مقالات حالياً', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 8),
                    if (isAdmin)
                      const Text('اضغط على + لنشر مقال جديد', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return _buildArticleCard(context, article, isAdmin);
              },
            );
          },
        ),
        floatingActionButton: isAdmin
            ? FloatingActionButton.extended(
                backgroundColor: AppTheme.primaryTeal,
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text('نشر مقال', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddArticlePage()));
                },
              )
            : null,
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Article article, bool isAdmin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailsScreen(article: article)));
        },
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Image.network(
                      article.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 180,
                        color: AppTheme.mintBackground,
                        child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                      ),
                    ),
                  ),
                  // gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                        ),
                      ),
                    ),
                  ),
                  if (isAdmin)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('مقال', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.summary,
                    style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                            child: const Icon(Icons.person, size: 14, color: AppTheme.primaryTeal),
                          ),
                          const SizedBox(width: 6),
                          Text(article.author, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            intl.DateFormat('yyyy/MM/dd').format(article.createdAt),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
