// lib/models/exam_type.dart
import 'package:flutter/material.dart';

enum ExamType {
  regularQuiz,
  majorExam;

  // For display names
  String get displayName {
    switch (this) {
      case ExamType.regularQuiz:
        return 'Regular Quiz';
      case ExamType.majorExam:
        return 'Major Exam';
    }
  }

  // For descriptions
  String get description {
    switch (this) {
      case ExamType.regularQuiz:
        return 'Quick assessment with 20 questions';
      case ExamType.majorExam:
        return 'Two-part exam: Written + Coding sections';
    }
  }

  // Icon for each type
  IconData get icon {
    switch (this) {
      case ExamType.regularQuiz:
        return Icons.quiz;
      case ExamType.majorExam:
        return Icons.assignment_turned_in;
    }
  }

  // Color theme
  Color get color {
    switch (this) {
      case ExamType.regularQuiz:
        return Colors.blue;
      case ExamType.majorExam:
        return Colors.purple;
    }
  }
}
