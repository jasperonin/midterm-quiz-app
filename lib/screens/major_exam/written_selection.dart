// lib/screens/major_exam/written_selection.dart
import 'package:flutter/material.dart';
import '../../models/quiz_data.dart';
import '../../services/tab_switch_detector.dart';
import '../../services/major_exam_service.dart';
import '../../widgets/quiz/question_card.dart';
import '../../widgets/quiz/choice_button.dart';
import '../../widgets/common/loading_indicator.dart';

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
  late MajorExamService _examService;

  List<Question> _questions = [];
  List<List<int>> _shuffledChoicesIndices = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  String? _errorMessage;

  // Track user answers locally
  Map<int, int> _userAnswers = {}; // questionIndex -> selectedOptionIndex

  @override
  void initState() {
    super.initState();
    _examService = MajorExamService(studentId: widget.studentId);
    widget.detector.startMonitoring();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _examService.loadWrittenQuestions();

      if (!mounted) return;

      if (questions.isEmpty) {
        setState(() {
          _errorMessage = 'No written questions available';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _questions = questions;
        _isLoading = false;
      });

      // Pre-shuffle choices
      _preShuffleChoices();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error loading questions: $e';
        _isLoading = false;
      });
    }
  }

  void _preShuffleChoices() {
    _shuffledChoicesIndices = [];
    for (var question in _questions) {
      List<int> indices = List.generate(
        question.options.length,
        (index) => index,
      );
      indices.shuffle();
      _shuffledChoicesIndices.add(indices);
    }
  }

  void _selectAnswer(int selectedIndex) {
    final question = _questions[_currentQuestionIndex];

    setState(() {
      _userAnswers[_currentQuestionIndex] = selectedIndex;

      // Check if correct
      if (selectedIndex == question.correctAnswerIndex) {
        _score += question.points;
      }
    });

    // Move to next question after a brief delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        if (_currentQuestionIndex + 1 >= _questions.length) {
          // All questions completed
          widget.onComplete(_score);
        } else {
          setState(() {
            _currentQuestionIndex++;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadQuestions();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Center(child: Text('No questions available'));
    }

    final question = _questions[_currentQuestionIndex];
    final shuffledIndices = _shuffledChoicesIndices[_currentQuestionIndex];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  const TextSpan(text: 'Question '),
                  TextSpan(
                    text: '${_currentQuestionIndex + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' / ${_questions.length}'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Question card
            QuestionCard(question: question.text, points: question.points),
            const SizedBox(height: 24),

            // Answer options using ChoiceButton
            ...shuffledIndices.asMap().entries.map((entry) {
              final displayIndex = entry.key;
              final actualIndex = entry.value;
              final option = question.options[actualIndex];
              final isSelected =
                  _userAnswers[_currentQuestionIndex] == actualIndex;

              return ChoiceButton(
                text: option,
                index: displayIndex,
                isSelected: isSelected,
                onTap: _userAnswers.containsKey(_currentQuestionIndex)
                    ? null // Disable if already answered
                    : () => _selectAnswer(actualIndex),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.detector.stopMonitoring();
    super.dispose();
  }
}
