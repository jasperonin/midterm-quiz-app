// lib/scripts/append_questions.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';

class QuestionAppender {
  static Future<void> appendFromJson(String quizId, String jsonPath) async {
    print('🚀 Starting question append to quiz: $quizId');
    print('═══════════════════════════════════════════');

    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized');

      // Read JSON file
      print('📂 Reading from: $jsonPath');
      final String jsonString = await rootBundle.loadString(jsonPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Get reference to existing quiz
      final quizRef = FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId);

      // Get current quiz data
      final quizDoc = await quizRef.get();

      if (!quizDoc.exists) {
        throw Exception('Quiz not found: $quizId');
      }

      Map<String, dynamic> existingData =
          quizDoc.data() as Map<String, dynamic>;
      List<dynamic> existingQuestions = existingData['questions'] ?? [];

      print('📊 Existing questions: ${existingQuestions.length}');

      // Prepare new questions (adjust IDs)
      List<Map<String, dynamic>> newQuestions = [];
      int nextId = existingQuestions.length + 1;

      for (var q in jsonData['questions']) {
        var newQ = Map<String, dynamic>.from(q);
        newQ['id'] = nextId++; // Assign new sequential ID
        newQuestions.add(newQ);
      }

      print('📝 New questions to add: ${newQuestions.length}');

      // Combine existing and new questions
      List<dynamic> allQuestions = [...existingQuestions, ...newQuestions];

      // Recalculate total points
      int totalPoints = 0;
      for (var q in allQuestions) {
        totalPoints +=
            (q['points'] as int?) ?? 2; // Default to 2 if not specified
      }

      // Update the quiz document
      await quizRef.update({
        'questions': allQuestions,
        'totalQuestions': allQuestions.length,
        'totalPoints': totalPoints,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('─────────────────────────────────────────');
      print('✅ APPEND COMPLETE!');
      print('📊 Previous questions: ${existingQuestions.length}');
      print('📊 Added questions: ${newQuestions.length}');
      print('📊 Total questions now: ${allQuestions.length}');
      print('📊 Total points: $totalPoints');
      print('═══════════════════════════════════════════');
    } catch (e) {
      print('❌ ERROR: $e');
      print('═══════════════════════════════════════════');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get quiz ID from command line or hardcode
  String quizId = '6jwCRFs2skwK13S4LQyq'; // Replace with your actual quiz ID
  String jsonPath = 'another-question.json'; // Path to new questions

  await QuestionAppender.appendFromJson(quizId, jsonPath);
}
