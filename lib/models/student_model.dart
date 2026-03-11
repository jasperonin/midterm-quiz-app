// lib/data/models/student_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_enums.dart';

class StudentModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final List<String> enrolledCourses;
  final Map<String, dynamic> performance;
  final StudentStatus status;
  final DateTime? lastActive;
  final int tabSwitchCount;

  StudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.enrolledCourses,
    required this.performance,
    required this.status,
    this.lastActive,
    required this.tabSwitchCount,
  });

  String get fullName => '$firstName $lastName';

  double get averageScore {
    final scores = _extractScores();
    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  int get quizzesTaken {
    final scores = performance['quizScores'] as List? ?? [];
    return scores.length;
  }

  List<double> _extractScores() {
    final scores = <double>[];
    final quizScores = performance['quizScores'] as List? ?? [];

    for (var quiz in quizScores) {
      if (quiz is Map && quiz['percentage'] != null) {
        scores.add((quiz['percentage'] as num).toDouble());
      }
    }

    return scores;
  }

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return StudentModel(
      id: doc.id,
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      email: data['email'] ?? '',
      enrolledCourses: List<String>.from(data['enrolledCourses'] ?? []),
      performance: data['performance'] ?? {},
      status: _parseStatus(data['status']),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
      tabSwitchCount: data['tabSwitchCount'] ?? 0,
    );
  }

  static StudentStatus _parseStatus(dynamic status) {
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'active':
          return StudentStatus.active;
        case 'inactive':
          return StudentStatus.inactive;
        case 'atrisk':
        case 'at_risk':
          return StudentStatus.atRisk;
      }
    }
    return StudentStatus.active;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'enrolledCourses': enrolledCourses,
      'performance': performance,
      'status': status.displayName.toLowerCase(),
      'lastActive': lastActive != null
          ? Timestamp.fromDate(lastActive!)
          : FieldValue.serverTimestamp(),
      'tabSwitchCount': tabSwitchCount,
    };
  }
}
