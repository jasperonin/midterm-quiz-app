// lib/widgets/student/exam_section.dart
import 'package:flutter/material.dart';

class ExamSection extends StatelessWidget {
  final int? codingScore;
  final int? writtenScore;
  final int maxScore;
  final DateTime? codingDate;
  final DateTime? writtenDate;
  final double average;
  final double weighted;
  final String course;
  final double weight;
  final VoidCallback onViewCode;
  final VoidCallback onRegrade;
  final VoidCallback onEditWritten;

  const ExamSection({
    super.key,
    required this.codingScore,
    required this.writtenScore,
    required this.maxScore,
    this.codingDate,
    this.writtenDate,
    required this.average,
    required this.weighted,
    required this.course,
    required this.weight,
    required this.onViewCode,
    required this.onRegrade,
    required this.onEditWritten,
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
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assignment,
                    size: 20,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'EXAM (${(weight * 100).toInt()}%)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Show based on course
            if (course == 'lecture') ...[
              // Written Exam for Lecture
              Row(
                children: [
                  const Text('Written:'),
                  const SizedBox(width: 8),
                  Text(
                    writtenScore != null
                        ? '$writtenScore/$maxScore'
                        : 'Not taken',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: writtenScore != null ? Colors.blue : Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  if (writtenDate != null)
                    Text(
                      _formatDate(writtenDate!),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onEditWritten,
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ] else ...[
              // Coding Exam for Lab
              Row(
                children: [
                  const Text('Coding:'),
                  const SizedBox(width: 8),
                  Text(
                    codingScore != null
                        ? '$codingScore/$maxScore'
                        : 'Not taken',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: codingScore != null ? Colors.blue : Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  if (codingDate != null)
                    Text(
                      _formatDate(codingDate!),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onViewCode,
                    child: const Text('View Code'),
                  ),
                  TextButton(
                    onPressed: onRegrade,
                    child: const Text('Re-grade'),
                  ),
                ],
              ),
            ],

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
                  _buildBreakdownLabel('Exam'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
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
