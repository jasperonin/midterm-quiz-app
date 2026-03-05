// lib/screens/major_exam/written_section.dart
import 'package:flutter/material.dart';
import '../../services/tab_switch_detector.dart';

class WrittenSection extends StatefulWidget {
  final String studentId;
  final String studentName;
  final TabSwitchDetector detector;
  final Function(int) onComplete;

  const WrittenSection({
    Key? key,
    required this.studentId,
    required this.studentName,
    required this.detector,
    required this.onComplete,
  }) : super(key: key);

  @override
  _WrittenSectionState createState() => _WrittenSectionState();
}

class _WrittenSectionState extends State<WrittenSection> {
  int _currentQuestion = 0;
  int _score = 0;
  
  // Placeholder questions - replace with actual questions from Firestore
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Sample written question 1?',
      'options': ['A', 'B', 'C', 'D'],
      'correct': 0,
    },
    {
      'question': 'Sample written question 2?',
      'options': ['A', 'B', 'C', 'D'],
      'correct': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    widget.detector.startMonitoring();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestion >= _questions.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onComplete(_score);
      });
      return const Center(child: Text('Loading next section...'));
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Question ${_currentQuestion + 1}/${_questions.length}'),
          const SizedBox(height: 20),
          Text(_questions[_currentQuestion]['question']),
          const SizedBox(height: 20),
          ..._questions[_currentQuestion]['options'].map<Widget>((option) {
            return ListTile(
              title: Text(option),
              onTap: () {
                setState(() {
                  if (_currentQuestion == _questions[_currentQuestion]['correct']) {
                    _score++;
                  }
                  _currentQuestion++;
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}