// lib/screens/teacher/widgets/graded_answer_section.dart
import 'package:flutter/material.dart';
import '../../../models/student_submission.dart';
import 'grading_code_viewer.dart';

class GradedAnswerSection extends StatelessWidget {
  final String difficulty;
  final List<CodingAnswer> answers;
  final int startIndex;
  final Function(int index, int? score, String feedback) onGrade;

  const GradedAnswerSection({
    Key? key,
    required this.difficulty,
    required this.answers,
    required this.startIndex,
    required this.onGrade,
  }) : super(key: key);

  Color _getDifficultyColor() {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (answers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getDifficultyColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _getDifficultyColor().withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                difficulty == 'easy' ? Icons.energy_savings_leaf :
                difficulty == 'medium' ? Icons.auto_awesome :
                Icons.bolt,
                size: 18,
                color: _getDifficultyColor(),
              ),
              const SizedBox(width: 8),
              Text(
                '${difficulty.toUpperCase()} SECTION (${answers.length} question${answers.length > 1 ? 's' : ''})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getDifficultyColor(),
                ),
              ),
            ],
          ),
        ),

        // Questions
        ...answers.asMap().entries.map((entry) {
          int localIndex = entry.key;
          int globalIndex = startIndex + localIndex;
          CodingAnswer answer = entry.value;
          
          return GradingCodeViewer(
            answer: answer,
            questionNumber: globalIndex + 1,
            onGrade: (score, feedback) => onGrade(globalIndex, score, feedback),
          );
        }).toList(),
      ],
    );
  }
}