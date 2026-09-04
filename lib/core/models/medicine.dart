import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine extends Equatable {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final List<String> uses;
  final String dosage;
  final List<String> sideEffects;
  final List<String> warnings;
  final String imageUrl;
  final DateTime createdAt;

  const Medicine({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.uses,
    required this.dosage,
    required this.sideEffects,
    required this.warnings,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Medicine.fromMap(Map<String, dynamic> map, String documentId) {
    return Medicine(
      id: documentId,
      name: map['name']?.toString() ?? '',
      scientificName: map['scientificName']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      uses: List<String>.from((map['uses'] as List?) ?? []),
      dosage: map['dosage']?.toString() ?? '',
      sideEffects: List<String>.from((map['sideEffects'] as List?) ?? []),
      warnings: List<String>.from((map['warnings'] as List?) ?? []),
      imageUrl: map['imageUrl']?.toString() ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'scientificName': scientificName,
      'description': description,
      'uses': uses,
      'dosage': dosage,
      'sideEffects': sideEffects,
      'warnings': warnings,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        scientificName,
        description,
        uses,
        dosage,
        sideEffects,
        warnings,
        imageUrl,
        createdAt,
      ];
}
