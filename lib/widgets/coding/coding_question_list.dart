// lib/screens/major_exam/widgets/coding_question_list.dart
import 'package:flutter/material.dart';
import '../../../models/coding_question.dart';
import 'coding_question_item.dart';

class CodingQuestionList extends StatelessWidget {
  final Map<String, List<CodingQuestion>> questions;
  final Map<int, String> answers;
  final Function(int, String) onAnswerChanged;
  final Map<int, bool> answeredStatus;

  const CodingQuestionList({
    super.key,
    required this.questions,
    required this.answers,
    required this.onAnswerChanged,
    required this.answeredStatus,
  });

  @override
  Widget build(BuildContext context) {
    // Define difficulty order
    final List<String> difficultyOrder = ['easy', 'medium', 'hard'];
    
    return ListView(
      children: [
        for (String difficulty in difficultyOrder)
          if (questions.containsKey(difficulty))
            for (var question in questions[difficulty]!) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CodingQuestionItem(
                  question: question,
                  currentCode: answers[question.id] ?? '',
                  onCodeChanged: (code) => onAnswerChanged(question.id, code),
                  isAnswered: answeredStatus[question.id] ?? false,
                ),
              ),
            ],
        
        // Add bottom padding for scroll
        const SizedBox(height: 20),
      ],
    );
  }
}