// lib/widgets/quiz/quiz_dialogs.dart
import 'package:flutter/material.dart';

class QuizDialogs {
  static void showViolationWarning(BuildContext context, int count) {
    int remaining = 2 - count;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Warning!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You switched away from the quiz tab.'),
            const SizedBox(height: 16),
            Text(
              'Violation $count of 2',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              remaining == 1
                  ? 'One more violation will terminate the quiz!'
                  : 'Please stay on this tab to continue.',
              style: TextStyle(color: Colors.grey[700]),
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

  static void showQuizComplete(
    BuildContext context,
    int score,
    int total,
    bool isOffline,
    VoidCallback onHome,
  ) {
    double percentage = (score / total) * 100;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quiz Complete!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (isOffline) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Score will sync when online',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: onHome, child: const Text('Return Home')),
        ],
      ),
    );
  }

  static void showTerminated(BuildContext context, {bool isTimeUp = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Icon(
          isTimeUp ? Icons.timer_off : Icons.gpp_bad,
          color: Colors.red,
          size: 48,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isTimeUp ? 'Time\'s Up!' : 'Quiz Terminated',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              isTimeUp
                  ? 'Your time has expired.'
                  : 'You switched tabs too many times.\nYour score will NOT be recorded.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Return Home'),
          ),
        ],
      ),
    );
  }

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
              'No Internet Connection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'You need to connect to the internet at least once\nto download the questions.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void showExamAlreadyTaken(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.lock, color: Colors.red, size: 48),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Exam Already Taken',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'You have already completed this exam.\n'
              'Multiple attempts are not allowed.\n\n'
              'Please contact your teacher if you believe this is an error.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Return Home'),
          ),
        ],
      ),
    );
  }
}
