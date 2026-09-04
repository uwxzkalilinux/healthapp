class MedicalTest {
  final String id;
  final String testName;
  final String purpose;
  final String normalRange;
  final String preparation;
  final String imageUrl;
  final DateTime createdAt;

  MedicalTest({
    required this.id,
    required this.testName,
    required this.purpose,
    required this.normalRange,
    required this.preparation,
    required this.imageUrl,
    required this.createdAt,
  });

  factory MedicalTest.fromMap(Map<String, dynamic> data, String id) {
    return MedicalTest(
      id: id,
      testName: data['testName'] ?? '',
      purpose: data['purpose'] ?? '',
      normalRange: data['normalRange'] ?? '',
      preparation: data['preparation'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt'] != null ? data['createdAt'].toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'testName': testName,
      'purpose': purpose,
      'normalRange': normalRange,
      'preparation': preparation,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
}
