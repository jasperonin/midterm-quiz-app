// lib/models/quiz_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizData {
  final String id;
  final String title;
  final String description;
  final List<Question> questions;
  final int? timeLimit;
  final int passingScore;
  final bool isPublished;
  final String createdBy;
  final DateTime createdAt;

  QuizData({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.timeLimit,
    required this.passingScore,
    required this.isPublished,
    required this.createdBy,
    required this.createdAt,
  });

  factory QuizData.fromMap(Map<String, dynamic> map, String id) {
    // Handle timeLimit
    int? timeLimit;
    if (map['timeLimit'] != null) {
      if (map['timeLimit'] is int) {
        timeLimit = map['timeLimit'];
      } else if (map['timeLimit'] is String) {
        timeLimit = int.tryParse(map['timeLimit']);
      }
    }

    // Handle passingScore
    int passingScore = 60;
    if (map['passingScore'] != null) {
      if (map['passingScore'] is int) {
        passingScore = map['passingScore'];
      } else if (map['passingScore'] is String) {
        passingScore = int.tryParse(map['passingScore']) ?? 60;
      }
    }

    // Handle questions list - MATCHING YOUR STRUCTURE
    List<Question> questions = [];
    if (map['questions'] != null && map['questions'] is List) {
      questions = (map['questions'] as List)
          .whereType<Map<String, dynamic>>()
          .map((q) => Question.fromMap(q))
          .toList();
    }

    return QuizData(
      id: id,
      title: map['title']?.toString() ?? 'Quiz',
      description: map['description']?.toString() ?? '',
      questions: questions,
      timeLimit: timeLimit,
      passingScore: passingScore,
      isPublished: map['isPublished'] == true,
      createdBy: map['createdBy']?.toString() ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory QuizData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return QuizData.fromMap(data, doc.id);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'timeLimit': timeLimit,
      'passingScore': passingScore,
      'isPublished': isPublished,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class Question {
  final String id; // Will use the 'id' field (number converted to string)
  final String text; // This is the 'question' field in your DB
  final List<String> options; // This comes from 'choices' array
  final int
  correctAnswerIndex; // Determined from choices where isCorrect == true
  final String? type; // The 'type' field in your DB (e.g., "Output")
  final int points; // The 'points' field in your DB

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    this.type,
    required this.points,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    debugPrint('🔍 Parsing question: ${map['question']}');

    // Get the question text (from 'question' field)
    String questionText = map['question']?.toString() ?? 'No question text';

    // Get the question ID (from 'id' field, could be number)
    String questionId = '';
    if (map['id'] != null) {
      if (map['id'] is int) {
        questionId = map['id'].toString();
      } else {
        questionId = map['id'].toString();
      }
    } else {
      questionId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // Get points (from 'points' field)
    int questionPoints = 2; // default
    if (map['points'] != null) {
      if (map['points'] is int) {
        questionPoints = map['points'];
      } else if (map['points'] is String) {
        questionPoints = int.tryParse(map['points']) ?? 2;
      }
    }

    // Get type (from 'type' field)
    String? questionType = map['type']?.toString();

    // Process choices array - MATCHING YOUR STRUCTURE
    List<String> optionsList = [];
    int correctIndex = -1;

    if (map['choices'] != null && map['choices'] is List) {
      final choices = map['choices'] as List;

      for (int i = 0; i < choices.length; i++) {
        final choice = choices[i];
        if (choice is Map<String, dynamic>) {
          // Add the choice text
          if (choice['text'] != null) {
            optionsList.add(choice['text'].toString());
          }

          // Check if this choice is correct
          if (choice['isCorrect'] == true) {
            correctIndex = i;
          }
        }
      }
    }

    return Question(
      id: questionId,
      text: questionText,
      options: optionsList,
      correctAnswerIndex: correctIndex,
      type: questionType,
      points: questionPoints,
    );
  }

  Map<String, dynamic> toMap() {
    // Reconstruct the original structure if needed
    List<Map<String, dynamic>> choices = [];
    for (int i = 0; i < options.length; i++) {
      choices.add({'text': options[i], 'isCorrect': i == correctAnswerIndex});
    }

    return {
      'id': int.tryParse(id) ?? id, // Convert back to number if possible
    };
  }
}
