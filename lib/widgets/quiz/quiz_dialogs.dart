// lib/widgets/quiz/quiz_dialogs.dart
import 'package:flutter/material.dart';
import '../../models/quiz_result.dart';

class QuizDialogs {
  // Show violation warning
  static void showViolationWarning(BuildContext context, int count) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.warning, color: Colors.orange, size: 48),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tab Switch Detected',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Warning $count of 2',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Switching tabs or apps during the exam is not allowed.\n'
              'One more violation will terminate your exam.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  // Show terminated dialog
  static void showTerminated(BuildContext context, {bool isTimeUp = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Icon(
          isTimeUp ? Icons.timer_off : Icons.block,
          color: Colors.red,
          size: 48,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isTimeUp ? 'Time\'s Up!' : 'Exam Terminated',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              isTimeUp
                  ? 'Your time has expired.'
                  : 'Maximum tab switches exceeded.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Return Home'),
          ),
        ],
      ),
    );
  }

  // Show exam already taken dialog
  static void showExamAlreadyTaken(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.info, color: Colors.blue, size: 48),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Exam Already Taken',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'You have already completed this exam.\n'
              'Each student can only take the exam once.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Return Home'),
          ),
        ],
      ),
    );
  }

  // Show no offline data dialog
  static void showNoOfflineData(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.cloud_off, color: Colors.red, size: 48),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No Offline Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'You are offline and no cached questions are available.\n'
              'Please connect to the internet to start the quiz.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  // Show quiz complete dialog
  static void showQuizComplete(
    BuildContext context,
    int score,
    int totalPoints,
    bool isOffline,
    VoidCallback onClose, {
    QuizResultData? results,
  }) {
    double percentage = (score / totalPoints) * 100;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quiz Complete!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Score: $score / $totalPoints',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            if (results != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      'Correct',
                      results.correctAnswers.toString(),
                      Colors.green,
                    ),
                    _buildStat(
                      'Wrong',
                      results.wrongAnswers.toString(),
                      Colors.red,
                    ),
                    _buildStat(
                      'Time',
                      _formatTime(results.timeSpent),
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
            if (isOffline) ...[
              const SizedBox(height: 16),
              const Icon(Icons.sync_problem, color: Colors.orange),
              const Text(
                'Results will sync when online',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onClose();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Show pause confirmation dialog
  static Future<bool?> showPauseConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pause Quiz'),
        content: const Text(
          'Do you want to pause the quiz? You can resume later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pause'),
          ),
        ],
      ),
    );
  }

  // Show resume dialog
  static void showResumeDialog(
    BuildContext context,
    int currentQuestion,
    int totalQuestions,
    VoidCallback onStartOver,
    VoidCallback onContinue,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.refresh, color: Colors.blue, size: 48),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Resume Quiz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'You have an unfinished quiz.\n'
              'Continuing from question $currentQuestion of $totalQuestions.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onStartOver();
            },
            child: const Text('Start Over'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onContinue();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  static Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  static String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
