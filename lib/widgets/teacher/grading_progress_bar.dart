// lib/screens/teacher/widgets/grading_progress_bar.dart
import 'package:flutter/material.dart';

class GradingProgressBar extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final int gradedCount;

  const GradingProgressBar({
    Key? key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.gradedCount,
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
              'Question ${currentIndex + 1} of $totalQuestions',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$gradedCount/$totalQuestions graded',
                style: TextStyle(
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (currentIndex + 1) / totalQuestions,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            gradedCount == totalQuestions ? Colors.green : Colors.teal,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}