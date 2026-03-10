import 'package:cloud_firestore/cloud_firestore.dart';

class QuizResultData {
  final String id;
  final String userId;
  final String quizId;
  final String sessionId;
  final double score;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int timeSpent;
  final List<Map<String, dynamic>> answers;
  final DateTime completedAt;

  QuizResultData({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.sessionId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeSpent,
    required this.answers,
    required this.completedAt,
  });

  factory QuizResultData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizResultData(
      id: doc.id,
      userId: data['userId'] ?? '',
      quizId: data['quizId'] ?? '',
      sessionId: data['sessionId'] ?? '',
      score: (data['score'] ?? 0).toDouble(),
      totalQuestions: data['totalQuestions'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      wrongAnswers: data['wrongAnswers'] ?? 0,
      timeSpent: data['timeSpent'] ?? 0,
      answers: List<Map<String, dynamic>>.from(data['answers'] ?? []),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'quizId': quizId,
      'sessionId': sessionId,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'timeSpent': timeSpent,
      'answers': answers,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }
}