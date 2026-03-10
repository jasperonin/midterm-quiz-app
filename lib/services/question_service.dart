import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/active_session.dart';
import '../models/quiz_data.dart';
import '../models/quiz_result.dart';
import 'session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionService _sessionService = SessionService();

  // ==================== PHASE 1: SESSION MANAGEMENT ====================

  // Validate and start quiz - now accepts userId directly
  Future<QuizStartResult> validateAndStartQuiz({
    required String userId,
    required String quizId,
    String? examId,
  }) async {
    try {
      // 1. Check session limit
      debugPrint('🎯 validateAndStartQuiz called');
      debugPrint('📋 userId: $userId');
      debugPrint('📋 quizId: $quizId');
      final canStart = await _sessionService.checkSessionLimit(userId);
      if (!canStart.allowed) {
        return QuizStartResult(success: false, error: canStart.message);
      }

      // 2. Get quiz data
      final quizDoc = await _firestore.collection('quizzes').doc(quizId).get();
      if (!quizDoc.exists) {
        return QuizStartResult(success: false, error: 'Quiz not found');
      }

      final randomizedQuestions = await getRandomizedQuestions(
        quizId,
        count: 20,
      );

      if (randomizedQuestions.isEmpty) {
        return QuizStartResult(
          success: false,
          error: 'No questions available for this quiz',
        );
      }
      final baseData = quizDoc.data()!;
      final quizData = QuizData(
        id: quizDoc.id,
        title: baseData['title'] ?? 'Quiz',
        description: baseData['description'] ?? '',
        questions: randomizedQuestions, // Use randomized questions
        timeLimit: baseData['timeLimit'] != null
            ? (baseData['timeLimit'] is int
                  ? baseData['timeLimit']
                  : int.tryParse(baseData['timeLimit'].toString()))
            : null,
        passingScore: baseData['passingScore'] ?? 60,
        isPublished: baseData['isPublished'] ?? false,
        createdBy: baseData['createdBy'] ?? '',
        createdAt:
            (baseData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

      // 3. Check for existing active quiz session
      final existingSession = await _checkExistingQuizSession(userId);
      if (existingSession != null) {
        return QuizStartResult(
          success: true,
          sessionId: existingSession.id,
          quizData: quizData,
          existingSession: true,
          lastQuestionIndex: existingSession.metadata.currentQuestion,
          savedAnswers: existingSession.metadata.answers,
        );
      }

      // 4. Create new quiz session
      final sessionId = await _createQuizSession(
        userId: userId,
        quizId: quizId,
        examId: examId,
        quizData: quizData,
      );

      // 5. Increment active sessions count
      await _sessionService.incrementActiveSessions(userId);

      return QuizStartResult(
        success: true,
        sessionId: sessionId,
        quizData: quizData,
        existingSession: false,
      );
    } on FirebaseException catch (e) {
      return QuizStartResult(
        success: false,
        error: 'Firebase error: ${e.message}',
      );
    } catch (e) {
      return QuizStartResult(success: false, error: 'Unexpected error: $e');
    }
  }

  // Check existing quiz session
  Future<ActiveSession?> _checkExistingQuizSession(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('activeSessions')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'quiz')
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return ActiveSession.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      debugPrint('Error checking existing session: $e');
      return null;
    }
  }

  // Create new quiz session
  Future<String> _createQuizSession({
    required String userId,
    required String quizId,
    String? examId,
    required QuizData quizData,
  }) async {
    final sessionRef = _firestore.collection('activeSessions').doc();

    final session = ActiveSession(
      id: sessionRef.id,
      userId: userId,
      type: SessionType.quiz,
      status: SessionStatus.active,
      startedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      metadata: SessionMetadata(
        quizId: quizId,
        examId: examId,
        title: quizData.title,
        totalQuestions: quizData.questions.length,
        currentQuestion: 0,
        answers: [],
        timeLimit: quizData.timeLimit,
        startedAt: DateTime.now(),
      ),
    );

    await sessionRef.set(session.toFirestore());
    return sessionRef.id;
  }

  // ==================== PHASE 2: ANSWER SUBMISSION ====================

  // Submit answer and update session
  Future<AnswerSubmissionResult> submitAnswer({
    required String sessionId,
    required int questionIndex,
    required int selectedOptionIndex,
    required int timeSpentSeconds,
  }) async {
    try {
      final sessionRef = _firestore.collection('activeSessions').doc(sessionId);
      final sessionDoc = await sessionRef.get();

      if (!sessionDoc.exists) {
        return AnswerSubmissionResult(
          success: false,
          error: 'Session not found',
        );
      }

      final session = ActiveSession.fromFirestore(sessionDoc);

      // Check if session is still active
      if (session.status != SessionStatus.active) {
        return AnswerSubmissionResult(
          success: false,
          error: 'This session is no longer active',
        );
      }

      // Check if this question was already answered
      Map<String, dynamic>? existingAnswer;
      for (var answer in session.metadata.answers) {
        if (answer['questionIndex'] == questionIndex) {
          existingAnswer = answer;
          break;
        }
      }

      if (existingAnswer != null) {
        return AnswerSubmissionResult(
          success: false,
          error: 'Question already answered',
          alreadyAnswered: true,
        );
      }

      // Get question data to check correctness
      final question = await _getQuestionById(
        session.metadata.quizId!,
        questionIndex,
      );

      // Determine if answer is correct (handle null case)
      final isCorrect = question != null
          ? question.correctAnswerIndex == selectedOptionIndex
          : false;

      // Create answer record
      final answer = {
        'questionIndex': questionIndex,
        'selectedOption': selectedOptionIndex,
        'isCorrect': isCorrect,
        'timeSpentSeconds': timeSpentSeconds,
        'submittedAt': DateTime.now().toIso8601String(),
      };

      // Update session
      final updatedAnswers = [...session.metadata.answers, answer];
      final nextQuestion = questionIndex + 1;
      final isCompleted = nextQuestion >= session.metadata.totalQuestions;

      await sessionRef.update({
        'metadata': {
          ...session.metadata.toFirestore(), // Convert existing metadata to map
          'answers': updatedAnswers,
          'currentQuestion': nextQuestion,
        },
        'lastActiveAt':
            FieldValue.serverTimestamp(), // This is fine (not in array)
        'status': isCompleted ? 'completed' : 'active',
      });
      // If quiz is completed, handle session cleanup and save results
      if (isCompleted) {
        await _handleQuizCompletion(
          userId: session.userId,
          sessionId: sessionId,
          quizId: session.metadata.quizId!,
          answers: updatedAnswers,
        );
      }

      return AnswerSubmissionResult(
        success: true,
        isCorrect: isCorrect,
        nextQuestionIndex: isCompleted ? null : nextQuestion,
        isCompleted: isCompleted,
        answer: answer,
      );
    } catch (e) {
      return AnswerSubmissionResult(success: false, error: e.toString());
    }
  }

  Future<List<Question>> getRandomizedQuestions(
    String quizId, {
    int count = 20,
  }) async {
    try {
      final cachedQuestions = await _getCachedQuestions(quizId);
      if (cachedQuestions != null && cachedQuestions.length >= count) {
        // Shuffle cached questions and take count
        final shuffled = List<Question>.from(cachedQuestions);
        shuffled.shuffle();
        final selected = shuffled.take(count).toList();
        debugPrint('🎲 Using cached questions, selected ${selected.length}');
        return selected;
      }
      debugPrint('🎲 Getting randomized questions for quiz: $quizId');

      // Get quiz document
      final quizDoc = await _firestore.collection('quizzes').doc(quizId).get();
      if (!quizDoc.exists) {
        debugPrint('❌ Quiz not found');
        return [];
      }

      final data = quizDoc.data();
      if (data == null) return [];

      // Get all questions
      final questionsData = data['questions'] as List?;
      if (questionsData == null || questionsData.isEmpty) {
        debugPrint('❌ No questions found');
        return [];
      }

      debugPrint('📚 Total questions available: ${questionsData.length}');

      // Convert to Question objects
      List<Question> allQuestions = [];
      for (var qData in questionsData) {
        if (qData is Map<String, dynamic>) {
          allQuestions.add(Question.fromMap(qData));
        }
      }

      // Shuffle the questions
      allQuestions.shuffle();
      debugPrint('🎲 Questions shuffled');

      // Take only the requested number of questions
      final selectedQuestions = allQuestions.take(count).toList();
      debugPrint('✅ Selected ${selectedQuestions.length} questions for quiz');

      // Store in local cache (you can implement shared_preferences here if needed)
      await _cacheQuestions(quizId, selectedQuestions);

      return selectedQuestions;
    } catch (e) {
      debugPrint('❌ Error getting randomized questions: $e');
      return [];
    }
  }

  // Cache questions locally (optional - implement with shared_preferences)
  Future<void> _cacheQuestions(String quizId, List<Question> questions) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert questions to JSON
      final questionsJson = questions.map((q) => q.toMap()).toList();
      final jsonString = jsonEncode(questionsJson);

      await prefs.setString('quiz_${quizId}_questions', jsonString);
      await prefs.setInt(
        'quiz_${quizId}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );

      debugPrint('💾 Cached ${questions.length} questions for quiz $quizId');
    } catch (e) {
      debugPrint('❌ Error caching questions: $e');
    }
  }

  // Get cached questions (optional)
  Future<List<Question>?> _getCachedQuestions(String quizId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final jsonString = prefs.getString('quiz_${quizId}_questions');
      final timestamp = prefs.getInt('quiz_${quizId}_timestamp');

      if (jsonString == null || timestamp == null) {
        return null;
      }

      // Check if cache is still valid (e.g., 24 hours)
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheAge = now - timestamp;
      final maxCacheAge = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

      if (cacheAge > maxCacheAge) {
        debugPrint('⌛ Cache expired for quiz $quizId');
        return null;
      }

      final List<dynamic> questionsJson = jsonDecode(jsonString);
      final questions = questionsJson
          .map((q) => Question.fromMap(q as Map<String, dynamic>))
          .toList();

      debugPrint(
        '📦 Loaded ${questions.length} questions from cache for quiz $quizId',
      );
      return questions;
    } catch (e) {
      debugPrint('❌ Error loading cached questions: $e');
      return null;
    }
  }

  // Get question by index
  // Update the _getQuestionById method
  Future<Question?> _getQuestionById(String quizId, int questionIndex) async {
    try {
      final quizDoc = await _firestore.collection('quizzes').doc(quizId).get();
      if (!quizDoc.exists) return null;

      final data = quizDoc.data();
      if (data == null) return null;

      final questions = data['questions'] as List?;
      if (questions == null || questionIndex >= questions.length) return null;

      final questionData = questions[questionIndex];
      if (questionData is! Map<String, dynamic>) return null;

      return Question.fromMap(questionData);
    } catch (e) {
      debugPrint('Error getting question: $e');
      return null;
    }
  }

  // Handle quiz completion
  Future<void> _handleQuizCompletion({
    required String userId,
    required String sessionId,
    required String quizId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final batch = _firestore.batch();

      // Update session status
      final sessionRef = _firestore.collection('activeSessions').doc(sessionId);
      batch.update(sessionRef, {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Decrement active sessions count
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {'activeSessions': FieldValue.increment(-1)});

      // Calculate and save quiz result
      final result = await _calculateQuizResult(quizId, answers);

      final resultRef = _firestore.collection('quizResults').doc();
      batch.set(resultRef, {
        'userId': userId,
        'quizId': quizId,
        'sessionId': sessionId,
        'score': result.score,
        'totalQuestions': result.totalQuestions,
        'correctAnswers': result.correctAnswers,
        'wrongAnswers': result.wrongAnswers,
        'timeSpent': result.totalTimeSpent,
        'answers': answers.map((answer) {
          // Make sure answers don't have serverTimestamp
          return {
            ...answer,
            'submittedAt': answer['submittedAt'] is String
                ? answer['submittedAt']
                : DateTime.now().toIso8601String(),
          };
        }).toList(),
        'completedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      debugPrint('Error handling quiz completion: $e');
    }
  }

  // Calculate quiz result
  Future<QuizResult> _calculateQuizResult(
    String quizId,
    List<Map<String, dynamic>> answers,
  ) async {
    try {
      final quizDoc = await _firestore.collection('quizzes').doc(quizId).get();
      final questions = quizDoc.data()?['questions'] as List? ?? [];

      int correctCount = 0;
      int totalTimeSpent = 0;

      for (var answer in answers) {
        if (answer['isCorrect'] == true) {
          correctCount++;
        }
        // Fix: Convert to int properly
        final timeSpent = answer['timeSpentSeconds'];
        if (timeSpent is int) {
          totalTimeSpent += timeSpent;
        } else if (timeSpent is num) {
          totalTimeSpent += timeSpent.toInt();
        }
      }

      final wrongCount = answers.length - correctCount;
      final score = questions.isNotEmpty
          ? (correctCount / questions.length) * 100
          : 0.0;

      return QuizResult(
        score: score,
        totalQuestions: questions.length,
        correctAnswers: correctCount,
        wrongAnswers: wrongCount,
        totalTimeSpent: totalTimeSpent,
      );
    } catch (e) {
      debugPrint('Error calculating result: $e');
      return QuizResult(
        score: 0,
        totalQuestions: 0,
        correctAnswers: 0,
        wrongAnswers: 0,
        totalTimeSpent: 0,
      );
    }
  }

  // ==================== PHASE 3: SESSION CONTROL ====================

  // Pause quiz session
  Future<bool> pauseQuizSession(String sessionId) async {
    try {
      await _firestore.collection('activeSessions').doc(sessionId).update({
        'status': 'paused',
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error pausing session: $e');
      return false;
    }
  }

  // Resume quiz session
  Future<ResumeSessionResult> resumeQuizSession(String sessionId) async {
    try {
      final sessionDoc = await _firestore
          .collection('activeSessions')
          .doc(sessionId)
          .get();

      if (!sessionDoc.exists) {
        return ResumeSessionResult(success: false, error: 'Session not found');
      }

      final session = ActiveSession.fromFirestore(sessionDoc);

      // Check if session can be resumed
      if (session.status == SessionStatus.completed) {
        return ResumeSessionResult(
          success: false,
          error: 'This quiz is already completed',
        );
      }

      if (session.status == SessionStatus.expired) {
        return ResumeSessionResult(
          success: false,
          error: 'This session has expired',
        );
      }

      // Update status back to active
      await _firestore.collection('activeSessions').doc(sessionId).update({
        'status': 'active',
        'lastActiveAt': FieldValue.serverTimestamp(),
      });

      // Get fresh quiz data
      final quizData = await _getQuizData(session.metadata.quizId!);

      return ResumeSessionResult(
        success: true,
        session: session,
        quizData: quizData,
        currentQuestionIndex: session.metadata.currentQuestion,
        savedAnswers: session.metadata.answers,
      );
    } catch (e) {
      return ResumeSessionResult(success: false, error: e.toString());
    }
  }

  // Get quiz data helper
  Future<QuizData?> _getQuizData(String quizId) async {
    try {
      final quizDoc = await _firestore.collection('quizzes').doc(quizId).get();
      if (!quizDoc.exists) return null;
      return QuizData.fromMap(quizDoc.data()!, quizDoc.id);
    } catch (e) {
      return null;
    }
  }

  // Abandon/close quiz session
  Future<bool> abandonQuizSession(String sessionId) async {
    try {
      final sessionDoc = await _firestore
          .collection('activeSessions')
          .doc(sessionId)
          .get();

      if (!sessionDoc.exists) return false;

      final session = ActiveSession.fromFirestore(sessionDoc);

      final batch = _firestore.batch();

      // Update session status
      batch.update(sessionDoc.reference, {
        'status': 'expired',
        'lastActiveAt': FieldValue.serverTimestamp(),
      });

      // Decrement active sessions count
      final userRef = _firestore.collection('users').doc(session.userId);
      batch.update(userRef, {'activeSessions': FieldValue.increment(-1)});

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error abandoning session: $e');
      return false;
    }
  }

  // ==================== PHASE 4: RESULTS & ANALYTICS ====================

  // Get quiz results
  Future<QuizResultData?> getQuizResults(String sessionId) async {
    try {
      final resultDoc = await _firestore
          .collection('quizResults')
          .where('sessionId', isEqualTo: sessionId)
          .limit(1)
          .get();

      if (resultDoc.docs.isEmpty) return null;

      return QuizResultData.fromFirestore(resultDoc.docs.first);
    } catch (e) {
      debugPrint('Error getting quiz results: $e');
      return null;
    }
  }

  // Get user's quiz history
  Future<List<QuizResultData>> getUserQuizHistory({
    required String userId,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('quizResults')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => QuizResultData.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting quiz history: $e');
      return [];
    }
  }

  // Get quiz statistics for a specific quiz
  Future<QuizStatistics> getQuizStatistics(String quizId) async {
    try {
      final resultsSnapshot = await _firestore
          .collection('quizResults')
          .where('quizId', isEqualTo: quizId)
          .get();

      if (resultsSnapshot.docs.isEmpty) {
        return QuizStatistics.empty();
      }

      double totalScore = 0;
      int totalTimeSpent = 0;
      final Map<int, int> questionDifficulty = {};

      for (var doc in resultsSnapshot.docs) {
        final data = doc.data();

        // Fix: Handle score conversion properly
        final score = data['score'];
        if (score is num) {
          totalScore += score.toDouble();
        }

        // Fix: Handle timeSpent conversion properly
        final timeSpent = data['timeSpent'];
        if (timeSpent is int) {
          totalTimeSpent += timeSpent;
        } else if (timeSpent is num) {
          totalTimeSpent += timeSpent.toInt();
        }

        // Track which questions were answered incorrectly
        final answers = data['answers'] as List? ?? [];
        for (var answer in answers) {
          if (answer['isCorrect'] == false) {
            final qIndex = answer['questionIndex'] as int;
            questionDifficulty[qIndex] = (questionDifficulty[qIndex] ?? 0) + 1;
          }
        }
      }

      final averageScore = resultsSnapshot.docs.isNotEmpty
          ? totalScore / resultsSnapshot.docs.length
          : 0.0;
      final averageTime = resultsSnapshot.docs.isNotEmpty
          ? totalTimeSpent / resultsSnapshot.docs.length
          : 0.0;

      return QuizStatistics(
        totalAttempts: resultsSnapshot.docs.length,
        averageScore: averageScore,
        averageTimeSpent: averageTime,
        difficultQuestions: questionDifficulty,
      );
    } catch (e) {
      debugPrint('Error getting quiz statistics: $e');
      return QuizStatistics.empty();
    }
  }

  // ==================== PHASE 5: SESSION CLEANUP ====================

  // Clean up expired sessions (can be called periodically)
  Future<void> cleanupExpiredSessions() async {
    try {
      final expiryTime = DateTime.now().subtract(const Duration(hours: 24));

      final expiredSessions = await _firestore
          .collection('activeSessions')
          .where('status', isEqualTo: 'active')
          .where('lastActiveAt', isLessThan: Timestamp.fromDate(expiryTime))
          .get();

      final batch = _firestore.batch();

      for (var session in expiredSessions.docs) {
        batch.update(session.reference, {'status': 'expired'});

        // Decrement user's active sessions count
        final userId = session.data()['userId'];
        final userRef = _firestore.collection('users').doc(userId);
        batch.update(userRef, {'activeSessions': FieldValue.increment(-1)});
      }

      await batch.commit();
      debugPrint('Cleaned up ${expiredSessions.docs.length} expired sessions');
    } catch (e) {
      debugPrint('Error cleaning up sessions: $e');
    }
  }

  // Validate session on app resume
  Future<SessionValidationResult> validateSession(String sessionId) async {
    try {
      final sessionDoc = await _firestore
          .collection('activeSessions')
          .doc(sessionId)
          .get();

      if (!sessionDoc.exists) {
        return SessionValidationResult(
          isValid: false,
          reason: 'Session not found',
        );
      }

      final session = ActiveSession.fromFirestore(sessionDoc);

      // Check if session expired (24 hours inactivity)
      final expiryThreshold = DateTime.now().subtract(
        const Duration(hours: 24),
      );
      if (session.lastActiveAt.isBefore(expiryThreshold)) {
        return SessionValidationResult(
          isValid: false,
          reason: 'Session expired due to inactivity',
        );
      }

      // Check if user still exists
      final userDoc = await _firestore
          .collection('users')
          .doc(session.userId)
          .get();
      if (!userDoc.exists) {
        return SessionValidationResult(
          isValid: false,
          reason: 'User not found',
        );
      }

      return SessionValidationResult(isValid: true, session: session);
    } catch (e) {
      return SessionValidationResult(isValid: false, reason: e.toString());
    }
  }
}

// ==================== RESULT CLASSES ====================

class QuizStartResult {
  final bool success;
  final String? sessionId;
  final QuizData? quizData;
  final bool? existingSession;
  final int? lastQuestionIndex;
  final List<Map<String, dynamic>>? savedAnswers;
  final String? error;

  QuizStartResult({
    required this.success,
    this.sessionId,
    this.quizData,
    this.existingSession,
    this.lastQuestionIndex,
    this.savedAnswers,
    this.error,
  });
}

class AnswerSubmissionResult {
  final bool success;
  final bool? isCorrect;
  final int? nextQuestionIndex;
  final bool? isCompleted;
  final Map<String, dynamic>? answer;
  final String? error;
  final bool alreadyAnswered;

  AnswerSubmissionResult({
    required this.success,
    this.isCorrect,
    this.nextQuestionIndex,
    this.isCompleted,
    this.answer,
    this.error,
    this.alreadyAnswered = false,
  });
}

class ResumeSessionResult {
  final bool success;
  final ActiveSession? session;
  final QuizData? quizData;
  final int? currentQuestionIndex;
  final List<Map<String, dynamic>>? savedAnswers;
  final String? error;

  ResumeSessionResult({
    required this.success,
    this.session,
    this.quizData,
    this.currentQuestionIndex,
    this.savedAnswers,
    this.error,
  });
}

class SessionValidationResult {
  final bool isValid;
  final String? reason;
  final ActiveSession? session;

  SessionValidationResult({required this.isValid, this.reason, this.session});
}

class QuizResult {
  final double score;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalTimeSpent;

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalTimeSpent,
  });
}

class QuizStatistics {
  final int totalAttempts;
  final double averageScore;
  final double averageTimeSpent;
  final Map<int, int> difficultQuestions;

  QuizStatistics({
    required this.totalAttempts,
    required this.averageScore,
    required this.averageTimeSpent,
    required this.difficultQuestions,
  });

  factory QuizStatistics.empty() {
    return QuizStatistics(
      totalAttempts: 0,
      averageScore: 0,
      averageTimeSpent: 0,
      difficultQuestions: {},
    );
  }
}
