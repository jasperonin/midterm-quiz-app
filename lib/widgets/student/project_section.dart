// lib/widgets/student/project_section.dart
import 'package:flutter/material.dart';

class ProjectSection extends StatelessWidget {
  final int? score;
  final int maxScore;
  final DateTime? date;
  final String? title;
  final String? feedback;
  final double weight;
  final VoidCallback onEdit;

  const ProjectSection({
    super.key,
    required this.score,
    required this.maxScore,
    this.date,
    this.title,
    this.feedback,
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
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder,
                    size: 20,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'PROJECT (${(weight * 100).toInt()}%)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (title != null && title!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  title!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),

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

            if (feedback != null && feedback!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                feedback!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

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
