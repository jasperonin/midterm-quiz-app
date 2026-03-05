import 'package:cloud_firestore/cloud_firestore.dart';

enum ExamStartStatus { allowed, alreadyTaken, alreadyActive }

class ExamStartCheck {
  final ExamStartStatus status;

  const ExamStartCheck(this.status);

  bool get canStart => status == ExamStartStatus.allowed;
}

class QuizAttemptService {
  QuizAttemptService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<ExamStartCheck> checkCanStartExam(String? studentId) async {
    if (studentId == null) {
      return const ExamStartCheck(ExamStartStatus.allowed);
    }

    final userDoc = await _firestore
        .collection('users')
        .doc(studentId)
        .get(const GetOptions(source: Source.serverAndCache));

    if (!userDoc.exists) {
      return const ExamStartCheck(ExamStartStatus.allowed);
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    final examStatus = userData['examStatus'] ?? 'inactive';
    final hasTakenExam = userData['hasTakenExam'] ?? false;

    if (hasTakenExam == true) {
      return const ExamStartCheck(ExamStartStatus.alreadyTaken);
    }
    if (examStatus == 'active') {
      return const ExamStartCheck(ExamStartStatus.alreadyActive);
    }
    return const ExamStartCheck(ExamStartStatus.allowed);
  }

  Future<void> setExamStatus({
    required String? studentId,
    required String status,
  }) async {
    if (studentId == null) return;

    await _firestore.collection('users').doc(studentId).set({
      'examStatus': status,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setHasTakenExam(String? studentId) async {
    if (studentId == null) return;

    await _firestore.collection('users').doc(studentId).set({
      'hasTakenExam': true,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveScoreToUserDocument({
    required String? studentId,
    required String? studentName,
    required String? quizId,
    required String quizTitle,
    required int score,
    required int totalPoints,
    required int secondsRemaining,
    required int quizDurationSeconds,
  }) async {
    if (studentId == null) return;

    final userRef = _firestore.collection('users').doc(studentId);
    final percentage = (score / totalPoints) * 100;
    final newScore = {
      'quizId': quizId ?? 'default_quiz',
      'quizTitle': quizTitle,
      'score': score,
      'totalPoints': totalPoints,
      'percentage': double.parse(percentage.toStringAsFixed(1)),
      'completedAt': DateTime.now().toIso8601String(),
      'timeSpent': quizDurationSeconds - secondsRemaining,
    };

    final userDoc = await userRef.get(
      const GetOptions(source: Source.serverAndCache),
    );

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final existingScores = List<dynamic>.from(userData['scores'] ?? []);
      existingScores.add(newScore);

      await userRef.set({
        'scores': existingScores,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    await userRef.set({
      'student_id': studentId,
      'last_name': studentName ?? '',
      'scores': [newScore],
      'examStatus': 'active',
      'hasTakenExam': true,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    });
  }
}
