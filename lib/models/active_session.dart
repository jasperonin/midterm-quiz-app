import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionType { quiz, written, coding }

enum SessionStatus { active, paused, completed, expired }

class ActiveSession {
  final String id;
  final String userId;
  final SessionType type;
  final SessionStatus status;
  final DateTime startedAt;
  final DateTime lastActiveAt;
  final SessionMetadata metadata;

  ActiveSession({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.startedAt,
    required this.lastActiveAt,
    required this.metadata,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'startedAt': Timestamp.fromDate(startedAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'metadata': metadata.toFirestore(),
    };
  }

  factory ActiveSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActiveSession(
      id: doc.id,
      userId: data['userId'],
      type: SessionType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
      ),
      status: SessionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
      ),
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp).toDate(),
      metadata: SessionMetadata.fromFirestore(data['metadata']),
    );
  }
}

class SessionMetadata {
  final String? quizId;
  final String? examId;
  final String? writtenId;
  final String title;
  final int totalQuestions;
  final int currentQuestion;
  final List<Map<String, dynamic>> answers;
  final int? timeLimit;
  final DateTime startedAt;

  SessionMetadata({
    this.quizId,
    this.examId,
    this.writtenId,
    required this.title,
    required this.totalQuestions,
    required this.currentQuestion,
    required this.answers,
    this.timeLimit,
    required this.startedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'quizId': quizId,
      'examId': examId,
      'writtenId': writtenId,
      'title': title,
      'totalQuestions': totalQuestions,
      'currentQuestion': currentQuestion,
      'answers': answers.map((answer) {
        // Ensure answers don't contain FieldValue
        return {
          'questionIndex': answer['questionIndex'],
          'selectedOption': answer['selectedOption'],
          'isCorrect': answer['isCorrect'],
          'timeSpentSeconds': answer['timeSpentSeconds'],
          'submittedAt': answer['submittedAt'] is String
              ? answer['submittedAt']
              : DateTime.now().toIso8601String(),
        };
      }).toList(),
      'timeLimit': timeLimit,
      'startedAt': startedAt.toIso8601String(),
    };
  }

  factory SessionMetadata.fromFirestore(Map<String, dynamic> data) {
    // Parse answers
    List<Map<String, dynamic>> answersList = [];
    if (data['answers'] != null && data['answers'] is List) {
      answersList = (data['answers'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    return SessionMetadata(
      quizId: data['quizId']?.toString(),
      examId: data['examId']?.toString(),
      writtenId: data['writtenId']?.toString(),
      title: data['title']?.toString() ?? '',
      totalQuestions: data['totalQuestions'] ?? 0,
      currentQuestion: data['currentQuestion'] ?? 0,
      answers: answersList,
      timeLimit: data['timeLimit'] != null
          ? (data['timeLimit'] is int
                ? data['timeLimit']
                : int.tryParse(data['timeLimit'].toString()))
          : null,
      startedAt: data['startedAt'] != null
          ? DateTime.parse(data['startedAt'].toString())
          : DateTime.now(),
    );
  }
}
