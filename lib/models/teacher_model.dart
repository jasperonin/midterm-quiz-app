// lib/data/models/teacher_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final List<String> assignedCourses;
  final Map<String, dynamic>? settings;
  final DateTime? createdAt;

  TeacherModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.assignedCourses,
    this.settings,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';
  int get courseCount => assignedCourses.length;

  factory TeacherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return TeacherModel(
      id: doc.id,
      firstName: data['firstName'] ?? data['first_name'] ?? '',
      lastName: data['lastName'] ?? data['last_name'] ?? '',
      email: data['email'] ?? '',
      assignedCourses: List<String>.from(data['assignedCourses'] ?? []),
      settings: data['settings'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'assignedCourses': assignedCourses,
      'settings': settings,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
