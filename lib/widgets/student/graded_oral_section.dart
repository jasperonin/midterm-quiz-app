// lib/widgets/student/graded_oral_section.dart
import 'package:flutter/material.dart';

class GradedOralSection extends StatelessWidget {
  final int? score;
  final int maxScore;
  final DateTime? date;
  final double weight;
  final VoidCallback onEdit;

  const GradedOralSection({
    super.key,
    required this.score,
    required this.maxScore,
    this.date,
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
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.mic,
                    size: 20,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'GRADED ORAL (${(weight * 100).toInt()}%)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Text('Score:'),
                const SizedBox(width: 8),
                Text(
                  score != null ? '$score/$maxScore' : 'Not set',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: score != null ? Colors.green.shade700 : Colors.grey,
                  ),
                ),
                const Spacer(),
                if (date != null)
                  Text(
                    _formatDate(date!),
                    style: TextStyle(color: Colors.grey.shade600),
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
                label: const Text('Edit'),
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
}
