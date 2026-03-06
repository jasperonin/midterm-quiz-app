// lib/services/major_exam_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MajorExamService {
  final String studentId;
  
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
      
      bool isCurrentlyTakingWritten = userData['isCurrentlyTakingWritten'] ?? false;
      bool isCurrentlyTakingCoding = userData['isCurrentlyTakingCoding'] ?? false;
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .set({
        'isCurrentlyTakingWritten': true,
        'writtenScore': score,
        'writtenCompletedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('✅ Written section marked as completed for $studentId');
    } catch (e) {
      print('❌ Error marking written completed: $e');
    }
  }
  
  // Start coding section
  Future<void> startCodingSection() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .set({
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
  newExam,        // Fresh start - show written section
  startWritten,   // Start written section
  resumeCoding,   // Skip to coding section
  completed,      // Exam already done - show message
}