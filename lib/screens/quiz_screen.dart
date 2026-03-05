// lib/screens/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../services/tab_switch_detector.dart';
import '../services/question_service.dart';
import '../services/connection_service.dart';
import '../widgets/quiz/offline_banner.dart';
import '../widgets/quiz/quiz_app_bar.dart';
import '../widgets/quiz/quiz_progress_bar.dart';
import '../widgets/quiz/question_card.dart';
import '../widgets/quiz/choice_button.dart';
import '../widgets/quiz/quiz_dialogs.dart';
import '../widgets/common/loading_indicator.dart';

class QuizScreen extends StatefulWidget {
  final String? studentId;
  final String? studentName;
  final String? quizId;

  const QuizScreen({super.key, this.studentId, this.studentName, this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late TabSwitchDetector _detector;
  late QuestionService _questionService;
  late ConnectionService _connection;
  late StreamSubscription<bool> _connectionSubscription;

  // Quiz data
  List<Map<String, dynamic>> _questions = [];
  List<List<int>> _shuffledChoicesIndices = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _quizTerminated = false;
  bool _timeUp = false;
  String? _errorMessage;
  String _quizTitle = '';

  // Connection state
  bool _isOffline = false;
  bool _showOfflineBanner = false;

  // Timer
  late Timer _timer;
  int _secondsRemaining = 3600; // 1 hour

  // Track user answers
  List<int?> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    debugPrint('📱 [QuizScreen] Initializing for student: ${widget.studentId}');

    _questionService = QuestionService();
    _connection = ConnectionService();

    // Initialize detector with studentId for per-user tab counting
    _detector = TabSwitchDetector(
      studentId: widget.studentId,
      onViolation: (count) {
        if (mounted) {
          setState(() {}); // Update UI
          if (count == 1) {
            QuizDialogs.showViolationWarning(context, count);
          }
        }
      },
      onMaxViolationsReached: _terminateQuiz,
    );

    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    // Initialize connection service
    await _connection.initialize();

    // Listen to connection changes
    _connectionSubscription = _connection.connectionStream.listen((
      isConnected,
    ) {
      if (mounted) {
        setState(() {
          _isOffline = !isConnected;
          _showOfflineBanner = !isConnected;
        });
      }

      if (!isConnected) {
        _showOfflineWarning();
      }
    });

    // Check exam status before proceeding
    bool canStart = await _canStartExam();

    if (!canStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        QuizDialogs.showExamAlreadyTaken(context);
      });
      return;
    }

    // Mark exam as active
    await _setExamStatus('active');

    // Load questions
    await _loadQuestions();
  }

  Future<bool> _canStartExam() async {
    if (widget.studentId == null) return true; // Guest mode

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .get(const GetOptions(source: Source.serverAndCache));

      if (!userDoc.exists) return true;

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String examStatus = userData['examStatus'] ?? 'inactive';
      bool hasTakenExam = userData['hasTakenExam'] ?? false;

      if (hasTakenExam) {
        debugPrint('🚫 Student ${widget.studentId} has already taken exam');
        return false;
      }

      if (examStatus == 'active') {
        debugPrint('🚫 Student ${widget.studentId} has active exam session');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error checking exam status: $e');

      if (!await _connection.hasInternetConnection()) {
        _showOfflineCheckDialog();
        return false;
      }

      return false;
    }
  }

  Future<void> _setExamStatus(String status) async {
    if (widget.studentId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .set({
            'examStatus': status,
            'lastActive': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      debugPrint('📝 Exam status set to: $status for ${widget.studentId}');
    } catch (e) {
      debugPrint('❌ Error setting exam status: $e');
    }
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Map<String, dynamic>> questions = await _questionService
          .getQuizQuestions(count: 20, forceRefresh: false);

      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
          _quizTitle = 'C Programming Quiz';
        });

        _userAnswers = List<int?>.filled(_questions.length, null);
        _preShuffleChoices();
        _startTimer();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _detector.startMonitoring();
        });

        debugPrint('✅ Quiz loaded with ${questions.length} questions');
      }
    } catch (e) {
      debugPrint('❌ Error loading questions: $e');

      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });

        if (!_connection.isConnected) {
          QuizDialogs.showNoOfflineData(context);
        }
      }
    }
  }

  void _preShuffleChoices() {
    _shuffledChoicesIndices = [];
    for (var i = 0; i < _questions.length; i++) {
      List<dynamic> choices = _questions[i]['choices'] ?? [];
      List<int> indices = List.generate(choices.length, (index) => index);
      indices.shuffle();
      _shuffledChoicesIndices.add(indices);
    }
  }

  List<String> _getCurrentChoices() {
    List<int> shuffledIndices = _shuffledChoicesIndices[_currentQuestionIndex];
    List<dynamic> choices = _questions[_currentQuestionIndex]['choices'] ?? [];
    return shuffledIndices
        .map((index) => choices[index]['text'].toString())
        .toList();
  }

  int _getOriginalChoiceIndex(int shuffledIndex) {
    return _shuffledChoicesIndices[_currentQuestionIndex][shuffledIndex];
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
        QuizDialogs.showTerminated(context, isTimeUp: true);
      }
    });
  }

  void _answerQuestion(int shuffledChoiceIndex) {
    if (_quizTerminated || _timeUp) return;

    int originalIndex = _getOriginalChoiceIndex(shuffledChoiceIndex);
    List<dynamic> choices = _questions[_currentQuestionIndex]['choices'] ?? [];
    bool isCorrect = choices[originalIndex]['isCorrect'] == true;
    int points = _questions[_currentQuestionIndex]['points'] ?? 2;

    _userAnswers[_currentQuestionIndex] = originalIndex;

    if (isCorrect) {
      setState(() {
        _score += points;
      });
      debugPrint('✅ Correct! +$points points');
    } else {
      debugPrint('❌ incorrect');
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
    _timer.cancel();
    await _detector.resetViolations();

    await _setHasTakenExam();

    if (widget.studentId != null) {
      await _saveScoreToUserDocument();
    }

    if (!mounted) return;

    QuizDialogs.showQuizComplete(
      context,
      _score,
      40,
      _isOffline,
      () => Navigator.popUntil(context, (route) => route.isFirst),
    );
  }

  Future<void> _setHasTakenExam() async {
    if (widget.studentId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .set({
            'hasTakenExam': true,
            'lastActive': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      debugPrint('✅ hasTakenExam set to true for ${widget.studentId}');
    } catch (e) {
      debugPrint('❌ Error setting hasTakenExam: $e');
    }
  }

  Future<void> _saveScoreToUserDocument() async {
    if (widget.studentId == null) return;

    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId);

      double percentage = (_score / 40) * 100;

      Map<String, dynamic> newScore = {
        'quizId': widget.quizId ?? 'default_quiz',
        'quizTitle': _quizTitle,
        'score': _score,
        'totalPoints': 40,
        'percentage': double.parse(percentage.toStringAsFixed(1)),
        'completedAt': DateTime.now().toIso8601String(),
        'timeSpent': 3600 - _secondsRemaining,
      };

      final userDoc = await userRef.get(
        const GetOptions(source: Source.serverAndCache),
      );

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> existingScores = userData['scores'] ?? [];
        existingScores.add(newScore);

        await userRef.set({
          'scores': existingScores,
          'lastActive': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
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
      }

      debugPrint('✅ Score saved to user document');
    } catch (e) {
      debugPrint('❌ Error saving score: $e');
    }
  }

  void _terminateQuiz() {
    if (_quizTerminated) return;

    _timer.cancel();
    _setHasTakenExam();
    _setExamStatus('inactive');

    setState(() {
      _quizTerminated = true;
    });

    QuizDialogs.showTerminated(context);
  }

  void _showOfflineWarning() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _questions.isEmpty
                    ? 'Offline - Using cached questions'
                    : 'You are offline - answers will sync when online',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showOfflineCheckDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.cloud_off, color: Colors.orange, size: 48),
        content: const Text(
          'Cannot verify exam status while offline.\n'
          'Please connect to the internet to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _detector.stopMonitoring();
    _connectionSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Offline banner
    Widget offlineBanner = OfflineBanner(
      isVisible: _showOfflineBanner,
      hasQuestions: _questions.isNotEmpty,
    );

    // Loading state
    if (_isLoading) {
      return Scaffold(
        body: Column(
          children: [
            offlineBanner,
            Expanded(
              child: LoadingIndicator(
                message: _isOffline
                    ? 'Loading from cache...'
                    : 'Loading quiz...',
              ),
            ),
          ],
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Scaffold(
        body: Column(
          children: [
            offlineBanner,
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
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
                        onPressed: _loadQuestions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (_questions.isEmpty) {
      return Scaffold(
        body: Column(
          children: [
            offlineBanner,
            Expanded(
              child: Center(
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
            ),
          ],
        ),
      );
    }

    // Quiz terminated or time up
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
    var currentQ = _questions[_currentQuestionIndex];
    var currentChoices = _getCurrentChoices();
    int remainingQuestions = _questions.length - _currentQuestionIndex - 1;

    return Scaffold(
      appBar: QuizAppBar(
        title: _quizTitle,
        currentIndex: _currentQuestionIndex,
        totalQuestions: _questions.length,
        timeRemaining: _secondsRemaining,
        isOffline: _isOffline,
        violationCount: _detector.violationCount,
      ),
      body: Column(
        children: [
          offlineBanner,
          Expanded(
            child: Padding(
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
                          Icon(
                            Icons.person,
                            color: Colors.blue.shade800,
                            size: 16,
                          ),
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
                  QuizProgressBar(
                    progress: (_currentQuestionIndex + 1) / _questions.length,
                    remaining: remainingQuestions,
                    hasViolation: _detector.violationCount >= 1,
                  ),

                  const SizedBox(height: 20),

                  // Question card
                  QuestionCard(
                    question: currentQ['question'] ?? '',
                    type: currentQ['type'] ?? 'Question',
                    points: currentQ['points'] ?? 2,
                  ),

                  const SizedBox(height: 20),

                  // Choices
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentChoices.length,
                      itemBuilder: (context, index) {
                        return ChoiceButton(
                          text: currentChoices[index],
                          index: index,
                          onTap: () => _answerQuestion(index),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
