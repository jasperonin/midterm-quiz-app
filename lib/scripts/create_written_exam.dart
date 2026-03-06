// lib/scripts/create_written_exam.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';

class CreateWrittenExam {
  static Future<void> migrate() async {
    print('🚀 Starting written exam migration...');
    print('═══════════════════════════════════════════');

    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized');

      // Read JSON file
      print('📂 Reading from: assets/another-question.json');
      final String jsonString = await rootBundle.loadString(
        'another-question.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Extract questions
      List<dynamic> questions = jsonData['questions'];

      print('📊 Found ${questions.length} written questions');

      // Calculate total points
      int totalPoints = 0;
      Map<String, int> typeCount = {};

      for (var q in questions) {
        int points = q['points'] ?? 2;
        totalPoints += points;

        String type = q['type'] ?? 'multiple_choice';
        typeCount[type] = (typeCount[type] ?? 0) + 1;
      }

      // Prepare written exam document
      Map<String, dynamic> writtenExamData = {
        'title': 'C Programming Written Exam',
        'description':
            'Multiple choice questions covering C programming concepts',
        'timeLimit': 60, // 1 hour in minutes
        'totalQuestions': questions.length,
        'totalPoints': totalPoints,
        'questionTypes': typeCount,
        'shuffleQuestions': true,
        'shuffleChoices': true,
        'questions': questions.map((q) {
          // Preserve the original format
          return {
            'id': q['id'],
            'type': q['type'] ?? 'multiple_choice',
            'points': q['points'] ?? 2,
            'question': q['question'], // Preserves \n for code formatting
            'choices': q['choices'] ?? [], // Array of {text, isCorrect}
            'difficulty': q['difficulty'] ?? 'medium',
          };
        }).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'version': '1.0',
        'status': 'active',
      };

      // Reference to majorExam/writtenQuestions
      final docRef = FirebaseFirestore.instance
          .collection('majorExam')
          .doc('writtenQuestions');

      // Check if document already exists
      final existingDoc = await docRef.get();

      if (existingDoc.exists) {
        print('⚠️  writtenQuestions document already exists!');
        print('📋 Existing data will be overwritten.');
        print('⏳ Waiting 3 seconds... (Ctrl+C to cancel)');
        await Future.delayed(const Duration(seconds: 3));
      }

      // Save to Firestore
      await docRef.set(writtenExamData);

      print('─────────────────────────────────────────');
      print('✅ WRITTEN EXAM CREATED SUCCESSFULLY!');
      print('📌 Collection: majorExam');
      print('📌 Document: writtenQuestions');
      print('📊 Questions: ${questions.length}');
      print('📊 Total Points: $totalPoints');
      print('📊 Question Types:');
      typeCount.forEach((type, count) {
        print('   • $type: $count');
      });
      print('─────────────────────────────────────────');

      // Print sample of first question for verification
      if (questions.isNotEmpty) {
        print('\n📝 Sample Question (ID: ${questions[0]['id']}):');
        print('   Type: ${questions[0]['type']}');
        print('   Points: ${questions[0]['points'] ?? 2}');
        print('   Question: ${questions[0]['question']}');
        print(
          '   Choices: ${(questions[0]['choices'] as List).length} options',
        );
      }

      print('═══════════════════════════════════════════');
    } catch (e) {
      print('❌ ERROR: $e');
      print('═══════════════════════════════════════════');
    }
  }
}

void main() async {
  print('🔄 Starting written exam creation...');
  print('⚠️  This will create/overwrite majorExam/writtenQuestions');
  print('⏳ Make sure your another-question.json is in the assets folder\n');

  WidgetsFlutterBinding.ensureInitialized();
  await CreateWrittenExam.migrate();
}
