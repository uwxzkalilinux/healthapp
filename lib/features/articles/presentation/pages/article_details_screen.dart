import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/article.dart';
import '../../../../core/services/article_service.dart';
import '../../../admin/presentation/pages/add_article_page.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import 'package:intl/intl.dart' as intl;
import 'package:share_plus/share_plus.dart';

class ArticleDetailsScreen extends StatelessWidget {
  final Article article;
  const ArticleDetailsScreen({super.key, required this.article});

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
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 260.0,
              pinned: true,
              backgroundColor: AppTheme.primaryTeal,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (article.imageUrl.isNotEmpty)
                      Image.network(article.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: AppTheme.primaryTeal)),
                    // Gradient overlay for readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    Share.share('مقال صحي مهم: ${article.title}\n\nاقرأ المزيد في تطبيق صحة+');
                  },
                ),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddArticlePage(articleToEdit: article)));
                      if (result == true && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(context),
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
                      article.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Author info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.mintBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppTheme.primaryTeal.withOpacity(0.2),
                            child: const Icon(Icons.person, color: AppTheme.primaryTeal, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(article.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    intl.DateFormat('yyyy/MM/dd').format(article.createdAt),
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Summary highlight
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.05),
                        border: const Border(right: BorderSide(color: AppTheme.primaryTeal, width: 4)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        article.summary,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Content images gallery
                    if (article.contentImages.isNotEmpty) ...[
                      const Text('📷 صور المقال', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: article.contentImages.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _showFullImage(context, article.contentImages[index]),
                              child: Container(
                                width: 280,
                                margin: const EdgeInsets.only(left: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        article.contentImages[index],
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          color: AppTheme.mintBackground,
                                          child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.zoom_in, color: Colors.white, size: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Content
                    Text(
                      article.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.9,
                        color: AppTheme.textPrimary,
                      ),
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

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف المقال'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا المقال نهائياً؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ArticleService().deleteArticle(article.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('حذف', style: TextStyle(color: AppTheme.alertRed)),
            ),
          ],
        ),
      ),
    );
  }
}
