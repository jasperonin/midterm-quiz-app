// lib/data/models/course_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String name;
  final String code;
  final String section;
  final String schedule;
  final String teacherId;
  final List<String> studentIds;
  final List<String> quizIds;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CourseModel({
    required this.id,
    required this.name,
    required this.code,
    required this.section,
    required this.schedule,
    required this.teacherId,
    required this.studentIds,
    required this.quizIds,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return CourseModel(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      section: data['section'] ?? '',
      schedule: data['schedule'] ?? '',
      teacherId: data['teacherId'] ?? '',
      studentIds: List<String>.from(data['studentIds'] ?? []),
      quizIds: List<String>.from(data['quizIds'] ?? []),
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'section': section,
      'schedule': schedule,
      'teacherId': teacherId,
      'studentIds': studentIds,
      'quizIds': quizIds,
      'metadata': metadata,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'section': section,
      'schedule': schedule,
      'teacherId': teacherId,
      'studentIds': studentIds,
      'quizIds': quizIds,
      'metadata': metadata,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Computed properties
  int get studentCount => studentIds.length;
  int get quizCount => quizIds.length;

  String get displayName => '$code - $name ($section)';
}
