// lib/widgets/student/quiz_section.dart
import 'package:flutter/material.dart';

class QuizSection extends StatelessWidget {
  final List<Map<String, dynamic>> quizzes;
  final double average;
  final double weighted;
  final double weight;
  final VoidCallback onEdit;

  const QuizSection({
    super.key,
    required this.quizzes,
    required this.average,
    required this.weighted,
    required this.weight,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.quiz,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'QUIZZES (${(weight * 100).toInt()}%)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quiz list
            ...quizzes
                .map(
                  (quiz) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            '#${quiz['number']}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _formatDate(quiz['date']),
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        Text(
                          '${quiz['score']}/${quiz['maxScore']}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),

            const Divider(height: 24),

            // Stats
            Row(
              children: [
                const Text('AVERAGE:'),
                const Spacer(),
                Text(
                  '${average.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                const Text('Breakdown:'),
                const SizedBox(width: 8),
                Text(
                  _buildBreakdownLabel('Quiz'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Edit button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Scores'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _buildBreakdownLabel(String category) {
    final percent = (weight * 100).toStringAsFixed(
      weight * 100 == (weight * 100).roundToDouble() ? 0 : 1,
    );
    return '${weighted.toStringAsFixed(1)} (ceiling) / $percent% $category';
  }
}
