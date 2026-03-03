// lib/screens/quiz_screen.dart
import 'package:flutter/material.dart';
import '../services/tab_switch_detector.dart';

class QuizScreen extends StatefulWidget {
  final String? studentId;

  const QuizScreen({Key? key, this.studentId, required String studentName}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late TabSwitchDetector _detector;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizTerminated = false;
  String? _terminationReason;

  // Hardcoded sample questions
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

  @override
  void initState() {
    super.initState();

    print('📱 QuizScreen initialized');

    // Initialize detector with callbacks
    _detector = TabSwitchDetector(
      onViolation: (count) {
        print('⚠️ Callback received: violation #$count');
        if (mounted) {
          setState(() {
            // This will rebuild the UI to show the updated counter
            _updateViolationCount(count);
          });
        }
      },
      onMaxViolationsReached: _terminateQuiz,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMonitoring();
    });
  }

  void _updateViolationCount(int count) {
    print('🔄 Updating UI with violation count: $count');
    // The setState in the callback will handle this
  }

  Future<void> _startMonitoring() async {
    print('🚀 Starting tab switch monitoring...');
    await _detector.startMonitoring();
    if (mounted) {
      setState(() {}); // Update UI with initial count
    }
  }

  void _terminateQuiz() {
    if (_quizTerminated || !mounted) return;

    print('❌ Quiz terminated due to max violations');

    setState(() {
      _quizTerminated = true;
      _terminationReason = 'Maximum tab switches exceeded (2)';
    });

    // Stop monitoring
    _detector.stopMonitoring();

    // Show termination dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Icon(Icons.cancel, color: Colors.red, size: 48),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quiz Terminated',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'You switched tabs too many times.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Your score will NOT be recorded.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text('Return to Home'),
          ),
        ],
      ),
    );
  }

  void _answerQuestion(int selectedIndex) {
    if (_quizTerminated) return;

    if (selectedIndex == _questions[_currentQuestionIndex]['correct']) {
      _score++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() async {
    print('✅ Quiz completed normally');

    // Stop monitoring
    _detector.stopMonitoring();

    // Reset violations for next quiz
    await _detector.resetViolations();

    // Show results
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Icon(Icons.check_circle, color: Colors.green, size: 48),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quiz Complete!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Your Score: $_score/${_questions.length}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (_detector.violationCount > 0) ...[
              SizedBox(height: 8),
              Text(
                '⚠️ ${_detector.violationCount} tab switch(es) detected',
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text('Return Home'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('🧹 QuizScreen disposed');
    _detector.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_quizTerminated) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz Terminated'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 80, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'Quiz Terminated',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(_terminationReason ?? 'Unknown reason'),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz ${_currentQuestionIndex + 1}/${_questions.length}'),
        centerTitle: true,
        actions: [
          // Show violation counter in app bar
          Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _detector.violationCount > 0
                  ? Colors.orange.shade100
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student ID display
            if (widget.studentId != null)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Student: ${widget.studentId}',
                  style: TextStyle(color: Colors.blue.shade800),
                ),
              ),

            SizedBox(height: 20),

            // Progress indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _detector.violationCount >= 1 ? Colors.orange : Colors.blue,
              ),
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
                          String.fromCharCode(65 + index),
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
