import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/article.dart';

class ArticleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'articles';

  Future<void> addArticle(Article article) async {
    await _firestore.collection(_collection).add(article.toMap());
  }

  Future<void> updateArticle(Article article) async {
    await _firestore.collection(_collection).doc(article.id).update(article.toMap());
  }

  Future<void> deleteArticle(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<List<Article>> getArticles() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final list = snapshot.docs.map((doc) => Article.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      print('Error fetching articles: $e');
      return [];
    }
  }

  Stream<List<Article>> getArticlesStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => Article.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
