// lib/models/student_submission.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentSubmission {
  final String studentId;
  final String studentName;
  final String status;
  final DateTime? submittedAt;
  final int totalScore;
  final List<CodingAnswer> answers;

  StudentSubmission({
    required this.studentId,
    required this.studentName,
    required this.status,
    this.submittedAt,
    required this.totalScore,
    required this.answers,
  });

  factory StudentSubmission.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    List<dynamic> answersJson = data['answers'] ?? [];

    List<CodingAnswer> answers = answersJson.map((a) {
      return CodingAnswer.fromJson(a is Map<String, dynamic> ? a : {});
    }).toList();

    return StudentSubmission(
      studentId: id,
      studentName: data['studentName']?.toString() ?? 'Unknown',
      status: data['status']?.toString() ?? 'pending',
      submittedAt: _parseDateTime(data['submittedAt']),
      totalScore: _parseInt(data['totalScore']) ?? 0,
      answers: answers,
    );
  }
}

class CodingAnswer {
  final int? questionId;
  final String difficulty;
  final String code;
  final DateTime? submittedAt;
  int? score;
  String? feedback;

  CodingAnswer({
    this.questionId,
    required this.difficulty,
    required this.code,
    this.submittedAt,
    this.score,
    this.feedback,
  });

  factory CodingAnswer.fromJson(Map<String, dynamic> json) {
    return CodingAnswer(
      questionId: _parseInt(json['questionId']),
      difficulty: json['difficulty']?.toString() ?? 'medium',
      code: json['code']?.toString() ?? '',
      submittedAt: _parseDateTime(json['submittedAt']),
      score: _parseInt(json['score']),
      feedback: json['feedback']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'difficulty': difficulty,
      'code': code,
      'submittedAt': submittedAt?.toIso8601String(),
      'score': score,
      'feedback': feedback,
    };
  }
}

// Helper function to safely parse int from dynamic
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is Map<String, dynamic>) {
    final seconds = value['_seconds'];
    if (seconds is num) {
      final nanoseconds = value['_nanoseconds'];
      final millis =
          (seconds * 1000).toInt() +
          ((nanoseconds is num ? nanoseconds : 0) / 1000000).round();
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
  }
  return null;
}
