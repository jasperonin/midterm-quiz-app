// lib/screens/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/tab_switch_detector.dart';
import 'dart:async';

class QuizScreen extends StatefulWidget {
  final String? studentId;
  final String? studentName;
  final String? quizId;

  const QuizScreen({Key? key, this.studentId, this.studentName, this.quizId})
    : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late TabSwitchDetector _detector;

  // Quiz data
  List<Map<String, dynamic>> _allQuestions = []; // All 40 questions
  List<Map<String, dynamic>> _quizQuestions = []; // Only 20 selected
  List<List<int>> _shuffledChoicesIndices = [];
  int _currentQuestionIndex = 0;
  int _score = 0; // Changed to 0/58 format

  // Timer
  late Timer _timer;
  int _secondsRemaining = 3600; // 1 hour = 3600 seconds
  bool _timeUp = false;

  // UI state
  bool _isLoading = true;
  bool _quizTerminated = false;
  String? _errorMessage;
  String _quizTitle = '';

  // Track user answers
  List<int?> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    print('📱 [QuizScreen] Initializing');

    _detector = TabSwitchDetector(
      onViolation: (count) {
        if (mounted) setState(() {});
      },
      onMaxViolationsReached: _terminateQuiz,
    );

    _checkAndLoadQuiz();
  }

  Future<void> _checkAndLoadQuiz() async {
    bool canStart = await _canStartExam();

    if (!canStart) {
      // Show message and go back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showExamAlreadyActiveDialog();
      });
      return;
    }

    // Mark exam as active
    await _setExamStatus('active');

    // Load quiz data
    _loadQuizData();
  }

  void _showExamAlreadyActiveDialog() {
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
              'Please contact your instructor if you believe this is an error.',
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

  @override
  void dispose() {
    _timer.cancel();
    _detector.stopMonitoring();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timeUp = true;
        _timer.cancel();
        _showTimeUpDialog();
      }
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.timer_off, color: Colors.red, size: 48),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Time\'s Up!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Your quiz has ended.'),
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

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  // In quiz_screen.dart, replace your _saveScoreToUserDocument with this:

  // In quiz_screen.dart, replace your _saveScoreToUserDocument with this:

  // In quiz_screen.dart - Update _saveScoreToUserDocument

  Future<void> _saveScoreToUserDocument() async {
    if (widget.studentId == null) return;

    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId);

      // Calculate percentage
      int totalPossiblePoints = 40;
      double percentage = (_score / totalPossiblePoints) * 100;

      // Create score entry
      Map<String, dynamic> newScore = {
        'quizId': widget.quizId ?? 'default_quiz',
        'quizTitle': _quizTitle,
        'score': _score,
        'totalPoints': totalPossiblePoints,
        'percentage': double.parse(percentage.toStringAsFixed(1)),
        'completedAt': DateTime.now().toIso8601String(),
        'timeSpent': 3600 - _secondsRemaining,
      };

      print('📝 Saving score: $_score/40 for ${widget.studentId}');

      // Get current user data
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> existingScores = userData['scores'] ?? [];
        existingScores.add(newScore);

        // 👇 ADD hasTakenExam HERE TOO (double guarantee)
        await userRef.set({
          'scores': existingScores,
          'lastActive': FieldValue.serverTimestamp(),
          'hasTakenExam': true, // Backup
        }, SetOptions(merge: true));

        print('✅ Score saved with hasTakenExam=true');
      } else {
        await userRef.set({
          'student_id': widget.studentId,
          'last_name': widget.studentName ?? '',
          'scores': [newScore],
          'examStatus': 'active',
          'hasTakenExam': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
        });

        print('✅ New user created with hasTakenExam=true');
      }
    } catch (e) {
      print('❌ Error saving score: $e');
    }
  }

  Future<void> _loadQuizData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔍 [QuizScreen] Loading quiz data...');

      DocumentSnapshot quizDoc;

      if (widget.quizId != null) {
        quizDoc = await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.quizId)
            .get();
      } else {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('quizzes')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) {
          throw Exception('No quizzes available');
        }
        quizDoc = snapshot.docs.first;
      }

      if (!quizDoc.exists) {
        throw Exception('Quiz not found');
      }

      Map<String, dynamic> quizData = quizDoc.data() as Map<String, dynamic>;

      setState(() {
        _quizTitle = quizData['title'] ?? 'Untitled Quiz';
        _allQuestions = List<Map<String, dynamic>>.from(
          quizData['questions'] ?? [],
        );
      });

      print('📋 [QuizScreen] Loaded: $_quizTitle');
      print('📊 [QuizScreen] Total questions in DB: ${_allQuestions.length}');

      // Randomize and select 20 questions
      _selectRandomQuestions();

      // Initialize user answers array
      _userAnswers = List<int?>.filled(_quizQuestions.length, null);

      // Pre-shuffle choices
      _preShuffleChoices();

      // Start timer
      _startTimer();

      // Start monitoring
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _detector.startMonitoring();
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [QuizScreen] Error loading quiz: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // In quiz_screen.dart - Enhanced debugging

  Future<void> _setHasTakenExam() async {
    if (widget.studentId == null) {
      print('❌ Cannot set hasTakenExam: studentId is null');
      return;
    }

    print('🔍 Setting hasTakenExam=true for ${widget.studentId}');

    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId);

      await userRef.set({
        'hasTakenExam': true,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ hasTakenExam set to true for ${widget.studentId}');
    } catch (e) {
      print('❌ Error setting hasTakenExam: $e');
    }
  }

  Future<bool> _canStartExam() async {
    if (widget.studentId == null) return true; // Guest mode always allowed

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .get();

      if (!userDoc.exists) return true; // New user, allow

      String examStatus = userDoc.data()?['examStatus'] ?? 'inactive';

      if (examStatus == 'active') {
        print('🚫 User ${widget.studentId} has already taken the exam');
        return false;
      }

      return true; // inactive = allowed
    } catch (e) {
      print('❌ Error checking exam status: $e');
      return false; // Fail closed - better to block on error
    }
  }

  Future<void> _setExamStatus(String status) async {
    if (widget.studentId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .update({
            'examStatus': status,
            'lastActive': FieldValue.serverTimestamp(),
          });
      print('📝 Exam status set to: $status');
    } catch (e) {
      print('❌ Error setting exam status: $e');
    }
  }

  void _selectRandomQuestions() {
    // Shuffle all questions
    List<Map<String, dynamic>> shuffled = List.from(_allQuestions);
    shuffled.shuffle();

    // Take first 20 (or all if less than 20)
    int takeCount = shuffled.length > 20 ? 20 : shuffled.length;
    _quizQuestions = shuffled.take(takeCount).toList();

    var _takeCount;
    print('🎲 Selected $_takeCount random questions for quiz');
  }

  void _preShuffleChoices() {
    _shuffledChoicesIndices = [];
    for (var i = 0; i < _quizQuestions.length; i++) {
      int choiceCount = _quizQuestions[i]['choices']?.length ?? 0;
      List<int> indices = List.generate(choiceCount, (index) => index);
      indices.shuffle(); // Always shuffle choices for variety
      _shuffledChoicesIndices.add(indices);
    }
  }

  List<Map<String, dynamic>> _getCurrentChoices() {
    List<dynamic> originalChoices =
        _quizQuestions[_currentQuestionIndex]['choices'] ?? [];
    List<int> shuffledIndices = _shuffledChoicesIndices[_currentQuestionIndex];

    return shuffledIndices
        .map((index) => Map<String, dynamic>.from(originalChoices[index]))
        .toList();
  }

  int _getOriginalChoiceIndex(int shuffledIndex) {
    return _shuffledChoicesIndices[_currentQuestionIndex][shuffledIndex];
  }

  void _answerQuestion(int shuffledChoiceIndex) {
    if (_quizTerminated || _timeUp) return;

    int originalIndex = _getOriginalChoiceIndex(shuffledChoiceIndex);
    var choices = _quizQuestions[_currentQuestionIndex]['choices'];
    bool isCorrect = choices[originalIndex]['isCorrect'] ?? false;
    int points = _quizQuestions[_currentQuestionIndex]['points'] ?? 1;

    // Store user's answer
    _userAnswers[_currentQuestionIndex] = originalIndex;

    if (isCorrect) {
      setState(() {
        _score += points;
      });
      print('✅ Correct! +$points points');
    } else {
      print('❌ Incorrect');
    }

    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() async {
    _timer.cancel();
    await _detector.resetViolations();

    // 👇 ADD THIS LINE - Set hasTakenExam to true
    await _setHasTakenExam();

    // Save score
    if (widget.studentId != null) {
      await _saveScoreToUserDocument();
    }

    if (!mounted) return;

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
            Text(
              'Score: $_score / 40',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Note: You cannot retake this quiz.\nContact your teacher if this is an error.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange),
              ),
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

  void _terminateQuiz() {
    if (_quizTerminated) return;

    _timer.cancel();

    // 👇 ADD THIS LINE - Set hasTakenExam to true even on termination
    _setHasTakenExam();

    // Reset exam status
    _setExamStatus('inactive');

    setState(() {
      _quizTerminated = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.gpp_bad, color: Colors.red, size: 48),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quiz Terminated',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'You switched tabs too many times.\nYour score will NOT be recorded.',
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

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text('Loading quiz...'),
            ],
          ),
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 20),
                Text(
                  'Error loading quiz',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(_errorMessage!),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadQuizData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Empty state
    if (_quizQuestions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.quiz, size: 60, color: Colors.grey),
              const SizedBox(height: 20),
              const Text('No questions available'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Quiz terminated state
    if (_quizTerminated || _timeUp) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_timeUp ? 'Time\'s Up' : 'Quiz Terminated'),
          backgroundColor: Colors.red,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _timeUp ? Icons.timer_off : Icons.block,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                _timeUp ? 'Time\'s Up!' : 'Quiz Terminated',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _timeUp
                    ? 'Your time has expired.'
                    : 'Maximum tab switches exceeded (2)',
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Return Home'),
              ),
            ],
          ),
        ),
      );
    }

    // Main quiz UI
    var currentQ = _quizQuestions[_currentQuestionIndex];
    var currentChoices = _getCurrentChoices();
    int remainingQuestions = _quizQuestions.length - _currentQuestionIndex - 1;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_quizTitle, style: const TextStyle(fontSize: 16)),
            Text(
              'Question ${_currentQuestionIndex + 1}/${_quizQuestions.length}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          // Timer
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _secondsRemaining < 300
                  ? Colors.red.shade100
                  : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: _secondsRemaining < 300 ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_secondsRemaining),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _secondsRemaining < 300
                        ? Colors.red.shade900
                        : Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),

          // Score
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student info
            if (widget.studentId != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue.shade800, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.studentName ?? 'Student'}: ${widget.studentId}',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Text(
                      '$remainingQuestions remaining',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _quizQuestions.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Question type and points
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentQ['type'] ?? 'Question',
                    style: TextStyle(
                      color: Colors.purple.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentQ['points'] ?? 1} pt${(currentQ['points'] ?? 1) > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Question text (preserves \n formatting)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SelectableText(
                currentQ['question'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontFamily: 'monospace',
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Choices
            Expanded(
              child: ListView.builder(
                itemCount: currentChoices.length,
                itemBuilder: (context, index) {
                  var choice = currentChoices[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(
                        choice['text'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
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
