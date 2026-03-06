// lib/screens/major_exam/coding_section.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../../models/coding_question.dart';
import '../../services/coding_question_service.dart';
import '../../widgets/coding/coding_difficulty_page.dart';
import '../../widgets/coding/coding_navigation_bar.dart';

class CodingSection extends StatefulWidget {
  final String studentId;
  final String studentName;
  final Function(int) onComplete;

  const CodingSection({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.onComplete,
  });

  @override
  _CodingSectionState createState() => _CodingSectionState();
}

class _CodingSectionState extends State<CodingSection> {
  final CodingQuestionService _service = CodingQuestionService();

  // State
  Map<String, List<CodingQuestion>> _questions = {};
  final List<String> _difficultyOrder = ['easy', 'medium', 'hard'];
  int _currentStep = 0;

  Map<int, String> _answers = {};
  Map<int, bool> _answeredStatus = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Timer
  late Timer _timer;
  int _secondsRemaining = 3600; // 1 hour
  bool _timeUp = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
    _loadLocalCache();
  }

  // In coding_section.dart, add this method inside _CodingSectionState

  Future<void> _submitAll() async {
    int totalEarned = _calculateTotalEarned();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Prepare answers for Firestore
      List<Map<String, dynamic>> answersList = [];

      _questions.forEach((difficulty, qList) {
        for (var q in qList) {
          answersList.add({
            'questionId': q.id,
            'difficulty': difficulty,
            'code': _answers[q.id] ?? '',
            'submittedAt': DateTime.now().toIso8601String(),
            'score': null,
            'feedback': null,
          });
        }
      });

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('codingExamAnswerByStudent')
          .doc(widget.studentId)
          .set({
            'studentId': widget.studentId,
            'studentName': widget.studentName,
            'answers': answersList,
            'submittedAt': FieldValue.serverTimestamp(),
            'status': 'S',
            'totalScore': 0,
          }, SetOptions(merge: true));

      print('✅ Answers submitted for ${widget.studentId}');

      // Clear cache after successful submission
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('coding_answers_${widget.studentId}');

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Submission Successful!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Your answers have been recorded.'),
              const SizedBox(height: 8),
              Text(
                'Total Score: $totalEarned',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Return Home'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.error, color: Colors.red, size: 48),
          content: Text('Failed to submit: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      print('❌ Error submitting answers: $e');
    }
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _service.loadAndSelectQuestions();

      setState(() {
        _questions = questions;
        _isLoading = false;
      });

      print(
        '✅ Loaded questions: Easy: ${_getQuestionsForDifficulty('easy').length}, '
        'Medium: ${_getQuestionsForDifficulty('medium').length}, '
        'Hard: ${_getQuestionsForDifficulty('hard').length}',
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<CodingQuestion> _getQuestionsForDifficulty(String difficulty) {
    return _questions[difficulty] ?? [];
  }

  // In coding_section.dart - Replace the _saveToCache method

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert answers map to JSON-safe format
      Map<String, String> answersForJson = {};
      _answers.forEach((key, value) {
        answersForJson[key.toString()] = value; // Convert int key to String
      });

      // Convert answered status map to JSON-safe format
      Map<String, bool> answeredForJson = {};
      _answeredStatus.forEach((key, value) {
        answeredForJson[key.toString()] = value; // Convert int key to String
      });

      final cacheData = {
        'answers': answersForJson,
        'answered': answeredForJson,
      };

      await prefs.setString(
        'coding_answers_${widget.studentId}',
        jsonEncode(cacheData),
      );

      print('💾 Saved to cache');
    } catch (e) {
      print('⚠️ Error saving to cache: $e');
    }
  }

  // Replace the _loadLocalCache method

  Future<void> _loadLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cached = prefs.getString(
        'coding_answers_${widget.studentId}',
      );

      if (cached != null) {
        final Map<String, dynamic> cachedMap = jsonDecode(cached);

        // Convert back from string keys to int keys
        final Map<int, String> loadedAnswers = {};
        final Map<String, dynamic> answersJson = cachedMap['answers'] ?? {};
        answersJson.forEach((key, value) {
          loadedAnswers[int.parse(key)] = value.toString();
        });

        final Map<int, bool> loadedStatus = {};
        final Map<String, dynamic> statusJson = cachedMap['answered'] ?? {};
        statusJson.forEach((key, value) {
          loadedStatus[int.parse(key)] = value == true;
        });

        setState(() {
          _answers = loadedAnswers;
          _answeredStatus = loadedStatus;
        });

        print('📦 Loaded ${_answers.length} answers from cache');
      }
    } catch (e) {
      print('⚠️ Error loading cache: $e');
    }
  }

  void _updateAnswer(int questionId, String code) {
    setState(() {
      _answers[questionId] = code;
      if (code.trim().isNotEmpty) {
        _answeredStatus[questionId] = true;
      } else {
        _answeredStatus[questionId] = false;
      }
    });
    _saveToCache(); // This will now work properly
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _timeUp = true;
        _timer.cancel();
        _autoSubmit();
      }
    });
  }

  void _autoSubmit() {
    int totalPoints = _calculateTotalEarned();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.timer_off, color: Colors.red, size: 48),
        content: const Text('Time\'s up! Your answers have been submitted.'),
        actions: [
          TextButton(
            onPressed: () => widget.onComplete(totalPoints),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  int _calculateTotalEarned() {
    int total = 0;
    _questions.forEach((_, qList) {
      for (var q in qList) {
        if (_answeredStatus[q.id] ?? false) {
          total += q.points;
        }
      }
    });
    return total;
  }

  int _getAnsweredCount() {
    return _answeredStatus.values.where((answered) => answered).length;
  }

  int _getTotalQuestions() {
    int count = 0;
    _questions.forEach((_, qList) => count += qList.length);
    return count;
  }

  bool _canGoNext() {
    if (_currentStep < _difficultyOrder.length - 1) {
      // Check if at least one question in current step is answered
      var currentQuestions = _getQuestionsForDifficulty(
        _difficultyOrder[_currentStep],
      );
      return currentQuestions.any((q) => _answeredStatus[q.id] ?? false);
    }
    return false;
  }

  bool _canGoPrevious() {
    return _currentStep > 0;
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadQuestions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    int totalQuestions = _getTotalQuestions();
    int answeredCount = _getAnsweredCount();
    String currentDifficulty = _difficultyOrder[_currentStep];
    var currentQuestions = _getQuestionsForDifficulty(currentDifficulty);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 👈 This removes the back button
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Coding Exam'),
            Text(
              '${currentDifficulty.toUpperCase()} SECTION',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: currentDifficulty == 'easy'
            ? Colors.green
            : currentDifficulty == 'medium'
            ? Colors.orange
            : Colors.red,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _secondsRemaining < 300
                  ? Colors.red.shade100
                  : Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: _secondsRemaining < 300 ? Colors.red : Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_secondsRemaining),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _secondsRemaining < 300
                        ? Colors.red.shade900
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Current difficulty page
          Expanded(
            child: CodingDifficultyPage(
              difficulty: currentDifficulty,
              questions: currentQuestions,
              answers: _answers,
              onAnswerChanged: _updateAnswer,
              answeredStatus: _answeredStatus,
            ),
          ),

          // Navigation bar
          CodingNavigationBar(
            currentStep: _currentStep,
            totalSteps: _difficultyOrder.length,
            canGoPrevious: _canGoPrevious(),
            canGoNext: _canGoNext(),
            isLastStep: _currentStep == _difficultyOrder.length - 1,
            onPrevious: () {
              setState(() {
                _currentStep--;
              });
            },
            onNext: () {
              setState(() {
                _currentStep++;
              });
            },
            onSubmit: () {
              _submitAll();
              int totalEarned = _calculateTotalEarned();
              widget.onComplete(totalEarned);
            },
            answeredCount: answeredCount,
            totalQuestions: totalQuestions,
          ),
        ],
      ),
    );
  }
}
