// lib/widgets/quiz/quiz_app_bar.dart
import 'package:flutter/material.dart';

class QuizAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int currentIndex;
  final int totalQuestions;
  final int timeRemaining;
  final bool isOffline;
  final int violationCount;

  const QuizAppBar({
    Key? key,
    required this.title,
    required this.currentIndex,
    required this.totalQuestions,
    required this.timeRemaining,
    required this.isOffline,
    required this.violationCount,
  }) : super(key: key);

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(
            'Question ${currentIndex + 1}/$totalQuestions',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      actions: [
        if (isOffline)
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.orange, size: 14),
                SizedBox(width: 4),
                Text('Offline', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
        Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: timeRemaining < 300 ? Colors.red.shade100 : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.timer,
                size: 16,
                color: timeRemaining < 300 ? Colors.red : Colors.blue,
              ),
              const SizedBox(width: 4),
              Text(
                _formatTime(timeRemaining),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: timeRemaining < 300 ? Colors.red.shade900 : Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}