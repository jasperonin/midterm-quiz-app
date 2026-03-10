// lib/widgets/attendance/grade_summary_header.dart
import 'package:flutter/material.dart';

class GradeSummaryHeader extends StatelessWidget {
  final int totalStudents;
  final int completed;
  final int pending;
  final int passed;
  final int failed;

  const GradeSummaryHeader({
    Key? key,
    required this.totalStudents,
    required this.completed,
    required this.pending,
    required this.passed,
    required this.failed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.people,
            value: totalStudents.toString(),
            label: 'Total',
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            value: completed.toString(),
            label: 'Completed',
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.pending,
            value: pending.toString(),
            label: 'Pending',
            color: Colors.orange,
          ),
          _buildStatItem(
            icon: Icons.emoji_events,
            value: passed.toString(),
            label: 'Passed',
            color: Colors.teal,
          ),
          _buildStatItem(
            icon: Icons.warning,
            value: failed.toString(),
            label: 'Failed',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
