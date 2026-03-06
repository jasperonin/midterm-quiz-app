// lib/screens/major_exam/widgets/coding_navigation_bar.dart
import 'package:flutter/material.dart';

class CodingNavigationBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool canGoPrevious;
  final bool canGoNext;
  final bool isLastStep;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;
  final int answeredCount;
  final int totalQuestions;

  const CodingNavigationBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.isLastStep,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
    required this.answeredCount,
    required this.totalQuestions,
  });

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Step indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < totalSteps; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == currentStep
                                ? _getStepColor(i)
                                : i < currentStep
                                    ? Colors.green
                                    : Colors.grey.shade300,
                          ),
                          child: Center(
                            child: i < currentStep
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      color: i == currentStep ? Colors.white : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                          ),
                        ),
                        if (i < totalSteps - 1)
                          Container(
                            width: 20,
                            height: 2,
                            color: i < currentStep
                                ? Colors.green
                                : Colors.grey.shade300,
                          ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${currentStep + 1} of $totalSteps',
                  style: TextStyle(
                    color: Colors.grey.shade600,
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
                    '$answeredCount/$totalQuestions answered',
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Navigation buttons
            Row(
              children: [
                // Previous button
                Expanded(
                  child: OutlinedButton(
                    onPressed: canGoPrevious ? onPrevious : null,
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
                    onPressed: isLastStep ? onSubmit : (canGoNext ? onNext : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLastStep 
                          ? Colors.teal 
                          : (canGoNext ? Colors.blue : Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLastStep) const Icon(Icons.send, size: 18),
                        if (isLastStep) const SizedBox(width: 8),
                        Text(isLastStep ? 'Submit All' : 'Next'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStepColor(int step) {
    switch (step) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}