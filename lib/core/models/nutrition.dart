class Nutrition {
  final String id;
  final String title;
  final String description;
  final List<String> benefits;
  final String calories;
  final String imageUrl;
  final DateTime createdAt;

  Nutrition({
    required this.id,
    required this.title,
    required this.description,
    required this.benefits,
    required this.calories,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Nutrition.fromMap(Map<String, dynamic> data, String id) {
    return Nutrition(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      benefits: List<String>.from(data['benefits'] ?? []),
      calories: data['calories'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt'] != null ? data['createdAt'].toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'benefits': benefits,
      'calories': calories,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
}
