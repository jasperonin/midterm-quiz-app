// lib/widgets/coding/coding_progress_bar.dart
import 'package:flutter/material.dart';

class CodingProgressBar extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final int answeredCount;

  const CodingProgressBar({
    Key? key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.answeredCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $currentQuestion of $totalQuestions',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$answeredCount/$totalQuestions answered',
                style: TextStyle(
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: currentQuestion / totalQuestions,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
        ),
      ],
    );
  }
}