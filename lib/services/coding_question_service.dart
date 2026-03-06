// lib/screens/major_exam/services/coding_question_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/coding_question.dart';

class CodingQuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, List<CodingQuestion>>> loadAndSelectQuestions() async {
    try {
      // Load all questions from Firestore
      final doc = await _firestore
          .collection('majorExam')
          .doc('codingQuestions')
          .get();

      if (!doc.exists) {
        throw Exception('Coding questions not found');
      }

      List<dynamic> allQuestions = doc.data()?['questions'] ?? [];
      
      // Group by difficulty
      Map<String, List<CodingQuestion>> grouped = {};
      
      for (var q in allQuestions) {
        CodingQuestion question = CodingQuestion.fromFirestore(q);
        String difficulty = question.difficulty;
        
        if (!grouped.containsKey(difficulty)) {
          grouped[difficulty] = [];
        }
        grouped[difficulty]!.add(question);
      }

      // Randomly select one from each difficulty
      Map<String, List<CodingQuestion>> selected = {};
      
      if (grouped.containsKey('easy')) {
        grouped['easy']!.shuffle();
        selected['easy'] = [grouped['easy']!.first];
      }
      
      if (grouped.containsKey('medium')) {
        grouped['medium']!.shuffle();
        selected['medium'] = [grouped['medium']!.first];
      }
      
      if (grouped.containsKey('hard')) {
        grouped['hard']!.shuffle();
        selected['hard'] = [grouped['hard']!.first];
      }

      print('✅ Selected questions: Easy: ${selected['easy']?.length}, '
            'Medium: ${selected['medium']?.length}, '
            'Hard: ${selected['hard']?.length}');

      return selected;
      
    } catch (e) {
      print('❌ Error loading coding questions: $e');
      rethrow;
    }
  }
}