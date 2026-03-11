// lib/screens/quiz_screen.dart
import 'package:app/services/question_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../services/tab_switch_detector.dart';
import '../services/connection_service.dart';
import '../models/quiz_data.dart';
import '../widgets/quiz/offline_banner.dart';
import '../widgets/quiz/quiz_app_bar.dart'; // Import the app bar
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
  late QuizService _quizService;
  late ConnectionService _connection;
  late StreamSubscription<bool> _connectionSubscription;

  // Quiz data
  QuizData? _quizData;
  List<Question> get _questions => _quizData?.questions ?? [];

  List<List<int>> _shuffledChoicesIndices = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _quizTerminated = false;
  bool _timeUp = false;
  String? _errorMessage;

  // Session management
  String? _sessionId;
  bool _isResuming = false;

  // Connection state
  bool _isOffline = false;
  bool _showOfflineBanner = false;

  // Timer
  Timer? _timer;
  int _secondsRemaining = 1800; // 30 minutes default
  int? _questionStartTime;

  // Track user answers locally for UI
  Map<int, int> _userAnswers = {}; // questionIndex -> selectedOptionIndex
  Map<int, bool> _answerResults = {}; // questionIndex -> isCorrect

  @override
  void initState() {
    super.initState();
    debugPrint('📱 [QuizScreen] Initializing for student: ${widget.studentId}');

    _quizService = QuizService();
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

    // Check if we have a quizId
    if (widget.quizId == null) {
      setState(() {
        _errorMessage = 'No quiz ID provided';
        _isLoading = false;
      });
      return;
    }

    // Check exam status before proceeding
    bool canStart = await _canStartExam();
    if (!canStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        QuizDialogs.showExamAlreadyTaken(context);
      });
      return;
    }

    // Validate and start quiz session
    await _startQuizSession();
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

  Future<void> _startQuizSession() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('🎯 Starting quiz session for student: ${widget.studentId}');
      debugPrint('📋 Quiz ID being used: ${widget.quizId}');

      if (widget.quizId == null) {
        setState(() {
          _errorMessage = 'Quiz ID is null';
          _isLoading = false;
        });
        return;
      }

      final result = await _quizService.validateAndStartQuiz(
        userId: widget.studentId ?? 'GUEST',
        quizId: widget.quizId!,
        examId: null,
      );

      if (!mounted) return;

      debugPrint(
        '📊 Quiz start result: success=${result.success}, error=${result.error}',
      );

      if (result.success) {
        setState(() {
          _quizData = result.quizData;
          _sessionId = result.sessionId;
          _isLoading = false;

          if (result.existingSession == true) {
            _isResuming = true;
            _currentQuestionIndex = result.lastQuestionIndex ?? 0;

            // Load saved answers
            if (result.savedAnswers != null) {
              for (var answer in result.savedAnswers!) {
                final qIndex = answer['questionIndex'] as int;
                final selected = answer['selectedOption'] as int;
                final isCorrect = answer['isCorrect'] as bool;

                _userAnswers[qIndex] = selected;
                _answerResults[qIndex] = isCorrect;

                // Update score
                if (isCorrect) {
                  _score += _getQuestionPoints(qIndex);
                }
              }
            }
          }
        });

        // Set time limit from quiz data
        if (_quizData?.timeLimit != null) {
          setState(() {
            _secondsRemaining = _quizData!.timeLimit! * 60;
          });
        }

        // Prepare shuffled choices
        _preShuffleChoices();

        // Start timer
        _startTimer();

        // Start monitoring
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _detector.startMonitoring();
        });

        // Show resume dialog if needed
        if (_isResuming) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            QuizDialogs.showResumeDialog(
              context,
              _currentQuestionIndex + 1,
              _questions.length,
              () async {
                // Start Over
                if (_sessionId != null) {
                  await _quizService.abandonQuizSession(_sessionId!);
                }
                _startQuizSession();
              },
              () {},
            );
          });
        }

        debugPrint('✅ Quiz session started: $_sessionId');
      } else {
        debugPrint('❌ Failed to start quiz: ${result.error}');
        setState(() {
          _errorMessage = result.error ?? 'Failed to start quiz';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error starting quiz: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  int _getQuestionPoints(int index) {
    if (_quizData != null && index < _quizData!.questions.length) {
      return _quizData!.questions[index].points;
    }
    return 2; // Default fallback
  }

  void _preShuffleChoices() {
    _shuffledChoicesIndices = [];
    for (var i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      List<int> indices = List.generate(
        question.options.length,
        (index) => index,
      );
      indices.shuffle();
      _shuffledChoicesIndices.add(indices);
    }
  }

  List<String> _getCurrentChoices() {
    if (_currentQuestionIndex >= _questions.length) return [];

    List<int> shuffledIndices = _shuffledChoicesIndices[_currentQuestionIndex];
    final question = _questions[_currentQuestionIndex];
    return shuffledIndices.map((index) => question.options[index]).toList();
  }

  int _getOriginalChoiceIndex(int shuffledIndex) {
    if (_currentQuestionIndex >= _shuffledChoicesIndices.length)
      return shuffledIndex;
    return _shuffledChoicesIndices[_currentQuestionIndex][shuffledIndex];
  }

  void _startTimer() {
    _questionStartTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _timeUp = true;
        _timer?.cancel();
        QuizDialogs.showTerminated(context, isTimeUp: true);
      }
    });
  }

  Future<void> _answerQuestion(int shuffledChoiceIndex) async {
    if (_quizTerminated || _timeUp || _sessionId == null) return;

    // Check if question already answered
    if (_userAnswers.containsKey(_currentQuestionIndex)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already answered this question'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Calculate time spent
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeSpent = _questionStartTime != null
        ? currentTime - _questionStartTime!
        : 0;

    int originalIndex = _getOriginalChoiceIndex(shuffledChoiceIndex);

    // Submit answer to server
    final result = await _quizService.submitAnswer(
      sessionId: _sessionId!,
      questionIndex: _currentQuestionIndex,
      selectedOptionIndex: originalIndex,
      timeSpentSeconds: timeSpent,
    );

    if (!mounted) return;

    if (result.success) {
      // Update local state
      setState(() {
        _userAnswers[_currentQuestionIndex] = originalIndex;
        _answerResults[_currentQuestionIndex] = result.isCorrect ?? false;

        if (result.isCorrect == true) {
          _score += _getQuestionPoints(_currentQuestionIndex);
        }
      });

      // Move to next question or complete
      if (result.isCompleted == true) {
        _completeQuiz();
      } else if (result.nextQuestionIndex != null) {
        setState(() {
          _currentQuestionIndex = result.nextQuestionIndex!;
          _questionStartTime = currentTime;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to submit answer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeQuiz() async {
    _timer?.cancel();
    await _detector.resetViolations();

    // Get results
    final results = await _quizService.getQuizResults(_sessionId!);

    if (!mounted) return;

    // Show completion dialog
    QuizDialogs.showQuizComplete(
      context,
      _score,
      _questions.length * 2,
      _isOffline,
      () => Navigator.popUntil(context, (route) => route.isFirst),
      results: results,
    );
  }

  void _terminateQuiz() {
    if (_quizTerminated) return;

    _timer?.cancel();

    // Abandon session
    if (_sessionId != null) {
      _quizService.abandonQuizSession(_sessionId!);
    }

    setState(() {
      _quizTerminated = true;
    });

    QuizDialogs.showTerminated(context);
  }

  Future<void> _handlePauseQuiz() async {
    final shouldPause = await QuizDialogs.showPauseConfirmation(context);

    if (shouldPause == true && _sessionId != null) {
      final success = await _quizService.pauseQuizSession(_sessionId!);
      if (success && mounted) {
        _timer?.cancel();
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Quiz paused')));
      }
    }
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
    _timer?.cancel();
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
                        onPressed: _startQuizSession,
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
    if (_currentQuestionIndex >= _questions.length) {
      return const Scaffold(body: Center(child: Text('Quiz completed!')));
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final currentChoices = _getCurrentChoices();
    final hasAnswered = _userAnswers.containsKey(_currentQuestionIndex);

    return WillPopScope(
      onWillPop: () async {
        _handlePauseQuiz();
        return false;
      },
      child: Scaffold(
        appBar: QuizAppBar(
          title: _quizData?.title ?? 'Quiz',
          currentIndex: _currentQuestionIndex,
          totalQuestions: _questions.length,
          timeRemaining: _secondsRemaining,
          isOffline: _isOffline,
          violationCount: _detector.violationCount,
          onPause: _handlePauseQuiz,
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
                      progress:
                          (_currentQuestionIndex + 1) /
                          _questions.length, // This will be /20
                      remaining: _questions.length - _currentQuestionIndex - 1,
                      hasViolation: _detector.violationCount >= 1,
                    ),

                    const SizedBox(height: 20),

                    // Question card
                    QuestionCard(
                      question: currentQuestion.text,
                      type: 'Question',
                      points: _getQuestionPoints(_currentQuestionIndex),
                    ),

                    const SizedBox(height: 20),

                    // Choices
                    Expanded(
                      child: ListView.builder(
                        itemCount: currentChoices.length,
                        itemBuilder: (context, index) {
                          final originalIndex = _getOriginalChoiceIndex(index);
                          final isSelected =
                              _userAnswers[_currentQuestionIndex] ==
                              originalIndex;
                          final isCorrect =
                              _answerResults[_currentQuestionIndex];

                          Color? customColor;
                          if (hasAnswered) {
                            if (isSelected) {
                              customColor = isCorrect == true
                                  ? Colors.green.shade100
                                  : Colors.red.shade100;
                            }
                          }

                          return ChoiceButton(
                            text: currentChoices[index],
                            index: index,
                            isSelected: isSelected,
                            customColor: customColor,
                            onTap: hasAnswered
                                ? null
                                : () => _answerQuestion(index),
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
      ),
    );
  }
}
