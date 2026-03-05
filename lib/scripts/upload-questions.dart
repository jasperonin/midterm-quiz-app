// lib/scripts/upload_questions.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import '../firebase_env_options.dart';

class QuestionUploader {
  static Future<void> uploadFromJson() async {
    print('🚀 Starting quiz upload...');
    print('═══════════════════════════════════════════');

    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: FirebaseEnvOptions.currentPlatform,
      );
      print('✅ Firebase initialized');

      // Read JSON file from assets
      print('📂 Reading from: lib/assets/question-quiz.json');
      final String jsonString = await rootBundle.loadString(
        'question-quiz.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Extract quiz metadata
      String quizTitle = jsonData['title'] ?? 'C Programming Quiz';
      bool shuffleQuestions = jsonData['shuffleQuestions'] ?? true;
      bool shuffleChoices = jsonData['shuffleChoices'] ?? true;
      int timeLimit = jsonData['timeLimitMinutes'] ?? 60;

      print('📋 Quiz: $quizTitle');
      print('📊 Total Questions: ${jsonData['questions'].length}');
      print('⏱️  Time Limit: $timeLimit minutes');
      print('🔀 Shuffle Questions: $shuffleQuestions');
      print('🔄 Shuffle Choices: $shuffleChoices');
      print('─────────────────────────────────────────');

      // Create a new quiz document in Firestore
      final quizRef = FirebaseFirestore.instance
          .collection('quizzes')
          .doc(); // Auto-generate ID

      // Prepare questions array exactly as in your JSON
      List<Map<String, dynamic>> questionsList = [];

      for (var q in jsonData['questions']) {
        print(
          '📝 Processing Q${q['id']}: ${q['type']} (${q['points']} point${q['points'] > 1 ? 's' : ''})',
        );

        questionsList.add({
          'id': q['id'],
          'type': q['type'],
          'points': q['points'],
          'question': q['question'], // Preserves \n for code formatting
          'choices': q['choices'], // Direct array of {text, isCorrect}
        });
      }

      // Calculate total points
      int totalPoints = questionsList.fold(
        0,
        (sum, q) => sum + (q['points'] as int),
      );

      // Upload to Firestore
      await quizRef.set({
        'title': quizTitle,
        'shuffleQuestions': shuffleQuestions,
        'shuffleChoices': shuffleChoices,
        'timeLimitMinutes': timeLimit,
        'totalQuestions': questionsList.length,
        'totalPoints': totalPoints,
        'questions': questionsList,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      print('─────────────────────────────────────────');
      print('✅ SUCCESS! Quiz uploaded to Firestore');
      print('📌 Quiz ID: ${quizRef.id}');
      print('📊 Questions: ${questionsList.length}');
      print('🏆 Total Points: $totalPoints');
      print('═══════════════════════════════════════════');
    } catch (e) {
      print('❌ ERROR: $e');
      print('═══════════════════════════════════════════');
    }
  }
}

// Run this function
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await QuestionUploader.uploadFromJson();
}
