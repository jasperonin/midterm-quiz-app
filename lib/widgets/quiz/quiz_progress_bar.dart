// lib/widgets/quiz/quiz_progress_bar.dart
import 'package:flutter/material.dart';

class QuizProgressBar extends StatelessWidget {
  final double progress;
  final int remaining;
  final bool hasViolation;

  const QuizProgressBar({
    Key? key,
    required this.progress,
    required this.remaining,
    required this.hasViolation,
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
              'Progress',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text(
              '$remaining remaining',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            hasViolation ? Colors.orange : Colors.blue,
          ),
        ),
      ],
    );
  }
}