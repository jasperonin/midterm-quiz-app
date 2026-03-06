// lib/screens/major_exam/widgets/coding_submit_button.dart
import 'package:flutter/material.dart';

class CodingSubmitButton extends StatelessWidget {
  final int answeredCount;
  final int totalQuestions;
  final VoidCallback onSubmit;
  final bool isEnabled;

  const CodingSubmitButton({
    super.key,
    required this.answeredCount,
    required this.totalQuestions,
    required this.onSubmit,
    this.isEnabled = true,
  });

  bool get allAnswered => answeredCount == totalQuestions;

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
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    allAnswered ? Icons.check_circle : Icons.pending,
                    size: 16,
                    color: allAnswered ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    allAnswered
                        ? 'All questions answered'
                        : '$answeredCount of $totalQuestions answered',
                    style: TextStyle(
                      color: allAnswered ? Colors.green.shade700 : Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isEnabled ? onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: allAnswered ? Colors.teal : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: allAnswered ? 4 : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send),
                    const SizedBox(width: 8),
                    Text(
                      allAnswered ? 'Submit All Answers' : 'Complete all questions to submit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Warning if not all answered
            if (!allAnswered && answeredCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'You can still submit, but unanswered questions will receive 0 points.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}