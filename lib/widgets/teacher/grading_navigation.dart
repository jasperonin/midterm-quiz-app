// lib/screens/teacher/widgets/grading_navigation_bar.dart
import 'package:flutter/material.dart';

class GradingNavigationBar extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final int totalScore;
  final int maxPossibleScore;
  final bool allGraded;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const GradingNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.totalScore,
    required this.maxPossibleScore,
    required this.allGraded,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  }) : super(key: key);

  bool get isFirst => currentIndex == 0;
  bool get isLast => currentIndex == totalQuestions - 1;

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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Score summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Score:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '$totalScore / $maxPossibleScore',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Navigation buttons
            Row(
              children: [
                // Previous button
                Expanded(
                  child: OutlinedButton(
                    onPressed: isFirst ? null : onPrevious,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Previous'),
                  ),
                ),

                const SizedBox(width: 12),

                // Next/Submit button
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLast ? onSubmit : onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLast
                          ? (allGraded ? Colors.green : Colors.teal)
                          : Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLast) const Icon(Icons.send, size: 18),
                        if (isLast) const SizedBox(width: 8),
                        Text(isLast ? 'Submit Final Grade' : 'Next'),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (!allGraded && isLast) ...[
              const SizedBox(height: 8),
              Text(
                'Not all questions are graded yet',
                style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
