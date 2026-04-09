// lib/widgets/student/hands_on_section.dart
import 'package:flutter/material.dart';

class HandsOnSection extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final double average;
  final double weighted;
  final double weight;
  final VoidCallback onAdd;
  final VoidCallback onEdit;

  const HandsOnSection({
    super.key,
    required this.activities,
    required this.average,
    required this.weighted,
    required this.weight,
    required this.onAdd,
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
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.handyman,
                    size: 20,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'HANDS-ON ACTIVITIES (${(weight * 100).toInt()}%)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Activity list
            ...activities
                .map(
                  (activity) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            activity['title'] ?? 'Act',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _formatDate(activity['date']),
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        Text(
                          '${activity['score']}/${activity['maxScore']}',
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
                  _buildBreakdownLabel('Hands-on'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
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
