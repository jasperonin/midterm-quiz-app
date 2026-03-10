// lib/widgets/attendance/grade_cell.dart
import 'package:flutter/material.dart';

class GradeCell extends StatelessWidget {
  final String label;
  final int? score;
  final Color? color;
  final VoidCallback? onTap;
  final bool isEditable;

  const GradeCell({
    Key? key,
    required this.label,
    this.score,
    this.color,
    this.onTap,
    this.isEditable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1) ?? Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color?.withOpacity(0.3) ?? Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
            Text(
              score?.toString() ?? '—',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
