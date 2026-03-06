// lib/screens/major_exam/widgets/coding_question_item.dart
import 'package:flutter/material.dart';
import '../../../models/coding_question.dart';
import '../../../widgets/coding/code_editor_field.dart';
import './diffuclty_header.dart';

class CodingQuestionItem extends StatelessWidget {
  final CodingQuestion question;
  final String currentCode;
  final Function(String) onCodeChanged;
  final bool isAnswered;

  const CodingQuestionItem({
    super.key,
    required this.question,
    required this.currentCode,
    required this.onCodeChanged,
    required this.isAnswered,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Difficulty header
            DifficultyHeader(
              difficulty: question.difficulty,
              points: question.points,
              isAnswered: isAnswered,
            ),
            
            const SizedBox(height: 12),
            
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
              const SizedBox(height: 12),
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
            
            // Code editor
            CodeEditorField(
              initialCode: currentCode,
              onCodeChanged: onCodeChanged,
              hintText: question.starterCode ?? '// Write your solution here...',
            ),
          ],
        ),
      ),
    );
  }
}