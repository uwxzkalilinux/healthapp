import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final String author;
  final DateTime createdAt;
  final List<String> contentImages;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.createdAt,
    this.contentImages = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
      'author': author,
      'createdAt': Timestamp.fromDate(createdAt),
      'contentImages': contentImages,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map, String id) {
    return Article(
      id: id,
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      author: map['author'] ?? 'د. محمد',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      contentImages: List<String>.from(map['contentImages'] ?? []),
    );
  }
}
