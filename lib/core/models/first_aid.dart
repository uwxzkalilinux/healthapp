class FirstAid {
  final String id;
  final String title;
  final String description;
  final List<String> steps;
  final String warnings;
  final String imageUrl;
  final DateTime createdAt;

  FirstAid({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.warnings,
    required this.imageUrl,
    required this.createdAt,
  });

  factory FirstAid.fromMap(Map<String, dynamic> data, String id) {
    return FirstAid(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      steps: List<String>.from(data['steps'] ?? []),
      warnings: data['warnings'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt'] != null ? data['createdAt'].toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'steps': steps,
      'warnings': warnings,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
}
