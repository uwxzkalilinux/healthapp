class HealthTip {
  final String id;
  final String title;
  final String content;
  final String category;
  final String imageUrl;
  final DateTime createdAt;

  HealthTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.createdAt,
  });

  factory HealthTip.fromMap(Map<String, dynamic> data, String id) {
    return HealthTip(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt'] != null ? data['createdAt'].toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
}
