// lib/screens/quiz_with_visibility.dart
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class QuizWithVisibility extends StatefulWidget {
  @override
  _QuizWithVisibilityState createState() => _QuizWithVisibilityState();
}

class _QuizWithVisibilityState extends State<QuizWithVisibility> {
  int _tabSwitchCount = 0;
  bool _quizTerminated = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('quiz-screen'),
      onVisibilityChanged: (VisibilityInfo info) {
        // This fires when tab visibility changes
        if (!_quizTerminated && info.visibleFraction == 0) {
          // User switched away
          setState(() {
            _tabSwitchCount++;
          });

          if (_tabSwitchCount >= 2) {
            _terminateQuiz();
          } else {
            _showWarning();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quiz'),
          actions: [
            if (_tabSwitchCount > 0) Container(padding: EdgeInsets.all(8)),
          ],
        ),
        body: _quizTerminated ? _buildTerminatedView() : _buildQuizContent(),
      ),
    );
  }

  void _showWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Warning: Tab switch detected ($_tabSwitchCount/2)'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _terminateQuiz() {
    setState(() {
      _quizTerminated = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Icon(Icons.cancel, color: Colors.red, size: 48),
        content: Text(
          'Quiz terminated due to multiple tab switches.\nYour score will not be recorded.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: Text('Return Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminatedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, size: 80, color: Colors.red),
          SizedBox(height: 20),
          Text('Quiz Terminated', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    // Your existing quiz UI
    return Center(child: Text('Quiz content here'));
  }
}
