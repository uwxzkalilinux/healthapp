import 'package:flutter/material.dart';

class MedicineReminder {
  final String id;
  final String userId;
  final String medicineName;
  final TimeOfDay time;
  final bool isActive;
  final String notes;
  final DateTime createdAt;

  MedicineReminder({
    required this.id,
    required this.userId,
    required this.medicineName,
    required this.time,
    this.isActive = true,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'medicineName': medicineName,
      'hour': time.hour,
      'minute': time.minute,
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicineReminder.fromMap(Map<String, dynamic> map, String id) {
    return MedicineReminder(
      id: id,
      userId: map['userId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      time: TimeOfDay(hour: map['hour'] ?? 8, minute: map['minute'] ?? 0),
      isActive: map['isActive'] ?? true,
      notes: map['notes'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}
