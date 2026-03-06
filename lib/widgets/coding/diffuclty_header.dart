// lib/screens/major_exam/widgets/difficulty_header.dart
import 'package:flutter/material.dart';

class DifficultyHeader extends StatelessWidget {
  final String difficulty;
  final int points;
  final bool isAnswered;

  const DifficultyHeader({
    super.key,
    required this.difficulty,
    required this.points,
    required this.isAnswered,
  });

  Color _getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getDifficultyIcon() {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.energy_savings_leaf;
      case 'medium':
        return Icons.auto_awesome;
      case 'hard':
        return Icons.bolt;
      default:
        return Icons.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getDifficultyColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getDifficultyColor().withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getDifficultyIcon(),
                  size: 16,
                  color: _getDifficultyColor(),
                ),
                const SizedBox(width: 4),
                Text(
                  difficulty.toUpperCase(),
                  style: TextStyle(
                    color: _getDifficultyColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$points pts',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          const Spacer(),
          if (isAnswered)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Answered',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}