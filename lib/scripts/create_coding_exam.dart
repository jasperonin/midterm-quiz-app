// lib/scripts/create_coding_exam.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';

class CreateCodingExam {
  static Future<void> migrate() async {
    print('🚀 Starting coding exam migration...');
    print('═══════════════════════════════════════════');
    
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized');
      
      // Read JSON file
      print('📂 Reading from: assets/coding-question.json');
      final String jsonString = await rootBundle.loadString('coding-question.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Extract questions
      List<dynamic> questions = jsonData['questions'];
      
      print('📊 Found ${questions.length} coding questions');
      
      // Calculate total points
      int totalPoints = 0;
      Map<String, int> difficultyCount = {
        'easy': 0,
        'medium': 0,
        'hard': 0,
      };
      
      for (var q in questions) {
        int points = q['points'] ?? 
            (q['difficulty'] == 'easy' ? 10 : 
             q['difficulty'] == 'medium' ? 15 : 25);
        totalPoints += points;
        
        String difficulty = q['difficulty'] ?? 'medium';
        difficultyCount[difficulty] = (difficultyCount[difficulty] ?? 0) + 1;
      }
      
      // Prepare coding questions document
      Map<String, dynamic> codingExamData = {
        'title': 'C Programming Coding Exam',
        'description': 'Practical coding assessment',
        'timeLimit': 60, // 3 hours in minutes
        'totalQuestions': questions.length,
        'totalPoints': totalPoints,
        'difficultyBreakdown': {
          'easy': difficultyCount['easy'],
          'medium': difficultyCount['medium'],
          'hard': difficultyCount['hard'],
        },
        'questions': questions.map((q) {
          return {
            'id': q['id'],
            'type': q['type'] ?? 'coding',
            'difficulty': q['difficulty'] ?? 'medium',
            'points': q['points'] ?? 
                (q['difficulty'] == 'easy' ? 10 : 
                 q['difficulty'] == 'medium' ? 15 : 25),
            'question': q['question'],
            'example_input': q['example_input'] ?? '',
            'example_output': q['example_output'] ?? '',
            'starterCode': q['starterCode'] ?? '// Write your solution here',
            'testCases': q['testCases'] ?? [],
            'constraints': q['constraints'] ?? ''
          };
        }).toList(),
        'version': '1.0',
        'status': 'active',
      };
      
      // Reference to majorExam/codingQuestions
      final docRef = FirebaseFirestore.instance
          .collection('majorExam')
          .doc('codingQuestions');
      
      // Check if document already exists
      final existingDoc = await docRef.get();
      
      if (existingDoc.exists) {
        print('⚠️  codingQuestions document already exists!');
        print('📋 Existing data will be overwritten.');
        print('⏳ Waiting 3 seconds... (Ctrl+C to cancel)');
        await Future.delayed(const Duration(seconds: 3));
      }
      
      // Save to Firestore
      await docRef.set(codingExamData);
      
      print('─────────────────────────────────────────');
      print('✅ CODING EXAM CREATED SUCCESSFULLY!');
      print('📌 Collection: majorExam');
      print('📌 Document: codingQuestions');
      print('📊 Questions: ${questions.length}');
      print('📊 Total Points: $totalPoints');
      print('📊 Difficulty Breakdown:');
      print('   • Easy: ${difficultyCount['easy']}');
      print('   • Medium: ${difficultyCount['medium']}');
      print('   • Hard: ${difficultyCount['hard']}');
      print('─────────────────────────────────────────');
      
      // Print sample of first question for verification
      if (questions.isNotEmpty) {
        print('\n📝 Sample Question (ID: ${questions[0]['id']}):');
        print('   Difficulty: ${questions[0]['difficulty']}');
        print('   Points: ${questions[0]['points'] ?? 
            (questions[0]['difficulty'] == 'easy' ? 10 : 
             questions[0]['difficulty'] == 'medium' ? 15 : 25)}');
        print('   Question: ${questions[0]['question']}');
      }
      
      print('═══════════════════════════════════════════');
      
    } catch (e) {
      print('❌ ERROR: $e');
      print('═══════════════════════════════════════════');
    }
  }
}

void main() async {
  print('🔄 Starting coding exam creation...');
  print('⚠️  This will create/overwrite majorExam/codingQuestions');
  print('⏳ Make sure your coding-question.json is in the assets folder\n');
  
  WidgetsFlutterBinding.ensureInitialized();
  await CreateCodingExam.migrate();
}