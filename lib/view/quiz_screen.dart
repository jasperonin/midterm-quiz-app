// lib/quiz_screen.dart
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String? studentId;
  final String? studentName;

  const QuizScreen({
    Key? key,
    this.studentId,
    this.studentName, // Add this
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;

  // Hardcoded sample questions for Phase 1
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is Flutter?',
      'options': [
        'A. A UI framework',
        'B. A database',
        'C. A programming language',
        'D. An operating system',
      ],
      'correct': 0,
    },
    {
      'question': 'Which language does Flutter use?',
      'options': ['A. Java', 'B. Kotlin', 'C. Dart', 'D. Swift'],
      'correct': 2,
    },
    {
      'question': 'What is a StatefulWidget?',
      'options': [
        'A. Static widget',
        'B. Widget that can change',
        'C. Widget without UI',
        'D. None of these',
      ],
      'correct': 1,
    },
  ];

  void _answerQuestion(int selectedIndex) {
    if (selectedIndex == _questions[_currentQuestionIndex]['correct']) {
      _score++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your Score: $_score/${_questions.length}'),
            SizedBox(height: 10),
            if (widget.studentId != null)
              Text(
                'Student ID: ${widget.studentId}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz ${_currentQuestionIndex + 1}/${_questions.length}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student ID display (if provided)
            if (widget.studentId != null && widget.studentName != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Student: ${widget.studentId} - ${widget.studentName}',
                      style: TextStyle(color: Colors.blue.shade800),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 20),

            // Progress indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

            SizedBox(height: 30),

            // Question text
            Text(
              'Question ${_currentQuestionIndex + 1}:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _questions[_currentQuestionIndex]['question'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),

            SizedBox(height: 30),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: _questions[_currentQuestionIndex]['options'].length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        _questions[_currentQuestionIndex]['options'][index],
                        style: TextStyle(fontSize: 16),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: TextStyle(color: Colors.blue.shade800),
                        ),
                      ),
                      onTap: () => _answerQuestion(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
