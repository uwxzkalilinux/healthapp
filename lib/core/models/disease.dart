import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Disease extends Equatable {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatment;
  final String imageUrl;
  final DateTime createdAt;

  const Disease({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.treatment,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Disease.fromMap(Map<String, dynamic> map, String documentId) {
    return Disease(
      id: documentId,
      name: map['name']?.toString() ?? '',
      scientificName: map['scientificName']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      symptoms: List<String>.from((map['symptoms'] as List?) ?? []),
      causes: List<String>.from((map['causes'] as List?) ?? []),
      treatment: List<String>.from((map['treatment'] as List?) ?? []),
      imageUrl: map['imageUrl']?.toString() ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'scientificName': scientificName,
      'description': description,
      'symptoms': symptoms,
      'causes': causes,
      'treatment': treatment,
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
        symptoms,
        causes,
        treatment,
        imageUrl,
        createdAt,
      ];
}
