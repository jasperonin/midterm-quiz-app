// lib/scripts/update_quiz_points.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';

class QuizPointsUpdater {
  static Future<void> updateAllQuizzesToTwoPoints() async {
    print('🚀 Starting quiz points update...');
    print('═══════════════════════════════════════════');
    
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized');
      
      // Get all quizzes
      final quizzesSnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .get();
      
      print('📊 Found ${quizzesSnapshot.docs.length} quizzes to update');
      
      int updatedCount = 0;
      int totalQuestionsUpdated = 0;
      
      // Process each quiz
      for (var quizDoc in quizzesSnapshot.docs) {
        print('─────────────────────────────────────────');
        print('📝 Processing quiz: ${quizDoc.id}');
        
        // Get the questions array
        List<dynamic> questions = List.from(quizDoc.data()['questions'] ?? []);
        int originalCount = questions.length;
        
        // Update each question's points to 2
        List<Map<String, dynamic>> updatedQuestions = [];
        for (var q in questions) {
          var questionMap = Map<String, dynamic>.from(q);
          questionMap['points'] = 2; // Set all to 2 points
          updatedQuestions.add(questionMap);
        }
        
        // Recalculate total points
        int newTotalPoints = updatedQuestions.length * 2;
        
        // Update the quiz document
        await quizDoc.reference.update({
          'questions': updatedQuestions,
          'totalPoints': newTotalPoints,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        
        updatedCount++;
        totalQuestionsUpdated += updatedQuestions.length;
        
        print('✅ Updated: ${updatedQuestions.length} questions');
        print('📊 New total points: $newTotalPoints');
      }
      
      print('═══════════════════════════════════════════');
      print('✅ UPDATE COMPLETE!');
      print('📊 Quizzes updated: $updatedCount');
      print('📊 Total questions updated: $totalQuestionsUpdated');
      print('📊 All questions now worth: 2 points');
      print('═══════════════════════════════════════════');
      
    } catch (e) {
      print('❌ ERROR: $e');
      print('═══════════════════════════════════════════');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await QuizPointsUpdater.updateAllQuizzesToTwoPoints();
}