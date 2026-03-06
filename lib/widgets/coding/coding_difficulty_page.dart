// lib/screens/major_exam/widgets/coding_difficulty_page.dart
import 'package:flutter/material.dart';
import '../../../models/coding_question.dart';
import '../../../widgets/coding/code_editor_field.dart';
import './diffuclty_header.dart';

class CodingDifficultyPage extends StatelessWidget {
  final String difficulty;
  final List<CodingQuestion> questions;
  final Map<int, String> answers;
  final Function(int, String) onAnswerChanged;
  final Map<int, bool> answeredStatus;

  const CodingDifficultyPage({
    super.key,
    required this.difficulty,
    required this.questions,
    required this.answers,
    required this.onAnswerChanged,
    required this.answeredStatus,
  });

  Color _getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Difficulty header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getDifficultyColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  difficulty == 'easy' ? Icons.energy_savings_leaf :
                  difficulty == 'medium' ? Icons.auto_awesome :
                  Icons.bolt,
                  color: _getDifficultyColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${difficulty.toUpperCase()} SECTION',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getDifficultyColor(),
                    ),
                  ),
                  Text(
                    '${questions.length} question${questions.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Questions for this difficulty
          ...questions.asMap().entries.map((entry) {
            int index = entry.key;
            CodingQuestion question = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question number
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: _getDifficultyColor().withOpacity(0.2),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getDifficultyColor(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Question ${index + 1} of ${questions.length}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${question.points} pts',
                            style: TextStyle(
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Question card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question text
                          Text(
                            question.question,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),

                          // Example I/O
                          if (question.exampleInput.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info, size: 14, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Example',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Input:  ${question.exampleInput}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Output: ${question.exampleOutput}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Answered indicator
                          if (answeredStatus[question.id] ?? false)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Answered',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Code editor
                          CodeEditorField(
                            initialCode: answers[question.id] ?? '',
                            onCodeChanged: (code) => onAnswerChanged(question.id, code),
                            hintText: question.starterCode ?? '// Write your solution here...',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}