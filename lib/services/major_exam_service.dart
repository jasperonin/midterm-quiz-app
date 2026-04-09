// lib/services/major_exam_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/quiz_data.dart';

class MajorExamService {
  final String studentId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MajorExamService({required this.studentId});

  // Check exam status and determine where to redirect
  Future<ExamResumeStatus> checkExamStatus() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .get();

      if (!userDoc.exists) {
        return ExamResumeStatus.newExam;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      bool isCurrentlyTakingWritten =
          userData['isCurrentlyTakingWritten'] ?? false;
      bool isCurrentlyTakingCoding =
          userData['isCurrentlyTakingCoding'] ?? false;
      bool hasTakenExam = userData['hasTakenExam'] ?? false;

      // Case 1: Already completed entire exam
      if (hasTakenExam) {
        return ExamResumeStatus.completed;
      }

      // Case 2: Currently in coding section
      if (isCurrentlyTakingCoding) {
        return ExamResumeStatus.resumeCoding;
      }

      // Case 3: Written section completed (flag true) but not in coding
      if (isCurrentlyTakingWritten) {
        return ExamResumeStatus.resumeCoding;
      }

      // Case 4: Fresh start or written in progress (flag false)
      return ExamResumeStatus.startWritten;
    } catch (e) {
      print('❌ Error checking exam status: $e');
      return ExamResumeStatus.newExam; // Default to new exam on error
    }
  }

  // Mark written section as completed
  Future<void> markWrittenCompleted({required int score}) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(studentId).set({
        'isCurrentlyTakingWritten': true,
        'writtenScore': score,
        'writtenCompletedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Written section marked as completed for $studentId');
    } catch (e) {
      print('❌ Error marking written completed: $e');
    }
  }

  // Load written questions from majorExam/writtenQuestions
  // Fetches all questions, randomizes per user, returns only 20
  Future<List<Question>> loadWrittenQuestions() async {
    try {
      final doc = await _firestore
          .collection('majorExam')
          .doc('writtenQuestions')
          .get();

      if (!doc.exists) {
        print('❌ Written questions document not found');
        return [];
      }

      final data = doc.data() as Map<String, dynamic>? ?? {};
      final questions = data['questions'] as List<dynamic>? ?? [];

      List<Question> allQuestions = questions
          .whereType<Map<String, dynamic>>()
          .map((q) => Question.fromMap(q))
          .toList();

      if (allQuestions.length <= 20) {
        return allQuestions;
      }

      // Randomize consistently per student using their ID as seed
      final seed = studentId.hashCode;
      final random = Random(seed);
      allQuestions.shuffle(random);

      // Return only first 20 questions
      return allQuestions.take(20).toList();
    } catch (e) {
      print('❌ Error loading written questions: $e');
      return [];
    }
  }

  // Start coding section
  Future<void> startCodingSection() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(studentId).set({
        'isCurrentlyTakingCoding': true,
        'codingStartedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Coding section started for $studentId');
    } catch (e) {
      print('❌ Error starting coding section: $e');
    }
  }
}

enum ExamResumeStatus {
  newExam, // Fresh start - show written section
  startWritten, // Start written section
  resumeCoding, // Skip to coding section
  completed, // Exam already done - show message
}
