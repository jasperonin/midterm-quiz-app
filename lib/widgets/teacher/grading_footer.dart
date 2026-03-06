// lib/widgets/teacher/grading_footer.dart
import 'package:flutter/material.dart';

class GradingFooter extends StatelessWidget {
  final int totalScore;
  final int maxPossibleScore;
  final bool allGraded;
  final VoidCallback onSubmit;

  const GradingFooter({
    Key? key,
    required this.totalScore,
    required this.maxPossibleScore,
    required this.allGraded,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Total Score'),
                  Text(
                    '$totalScore / $maxPossibleScore',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: allGraded ? Colors.green : Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(allGraded ? 'Submit Grades' : 'Save Progress'),
            ),
          ],
        ),
      ),
    );
  }
}