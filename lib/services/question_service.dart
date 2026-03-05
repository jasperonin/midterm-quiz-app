// lib/services/question_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'connection_service.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectionService _connection = ConnectionService();

  List<Map<String, dynamic>>? _cachedQuestions;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(hours: 1);

  // 👇 REPLACE THIS WITH YOUR ACTUAL QUIZ ID FROM FIRESTORE
  static const String _quizId = '6jwCRFs2skwK13S4LQyq';

  // Example: if your document ID is "c_programming_quiz"
  // static const String _quizId = 'c_programming_quiz';

  // Example: if it's an auto-generated ID
  // static const String _quizId = '4hT9cM2kLpA7qR5s';

  Future<List<Map<String, dynamic>>> getQuizQuestions({
    int count = 20,
    bool forceRefresh = false,
  }) async {
    try {

      // Check cache first
      if (!forceRefresh && _hasValidCache()) {
        print('📦 Using cached questions (${_cachedQuestions!.length})');
        return _getRandomQuestions(_cachedQuestions!, count);
      }

      bool hasInternet = await _connection.hasInternetConnection();

      if (hasInternet) {
        // Online: Fetch from Firestore
        print('🌐 Fetching questions from Firestore...');
        final doc = await _firestore.collection('quizzes').doc(_quizId).get();

        if (doc.exists) {
          print('✅ Quiz document found!');
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          List<dynamic> questionsJson = data['questions'] ?? [];

          print('📊 Found ${questionsJson.length} questions in quiz');

          if (questionsJson.isEmpty) {
            throw Exception('Quiz has no questions');
          }

          _cachedQuestions = questionsJson.map((q) {
            return Map<String, dynamic>.from(q);
          }).toList();

          _lastFetchTime = DateTime.now();
          print('✅ Cached ${_cachedQuestions!.length} questions');
        } else {
          print('❌ Quiz document not found with ID: $_quizId');
          print('💡 Available quizzes:');

          // List all available quizzes to help debug
          final snapshot = await _firestore.collection('quizzes').get();
          for (var doc in snapshot.docs) {
            print('   - ${doc.id}: ${doc.data()['title'] ?? 'Untitled'}');
          }

          throw Exception('Quiz not found. Check your quiz ID.');
        }
      } else {
        // Offline mode
        print('📴 Offline mode - checking cache...');
        if (_cachedQuestions != null && _cachedQuestions!.isNotEmpty) {
          print('✅ Using in-memory cache');
          return _getRandomQuestions(_cachedQuestions!, count);
        }

        throw Exception(
          'No questions available offline. Please connect to internet first.',
        );
      }

      if (_cachedQuestions == null || _cachedQuestions!.isEmpty) {
        throw Exception('No questions available');
      }

      return _getRandomQuestions(_cachedQuestions!, count);
    } catch (e) {
      print('❌ Error loading questions: $e');
      rethrow;
    }
  }

  bool _hasValidCache() {
    if (_cachedQuestions == null) return false;
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  List<Map<String, dynamic>> _getRandomQuestions(
    List<Map<String, dynamic>> allQuestions,
    int count,
  ) {
    if (allQuestions.isEmpty) return [];
    List<Map<String, dynamic>> shuffled = List.from(allQuestions);
    shuffled.shuffle();
    return shuffled.take(count).toList();
  }

  void clearCache() {
    _cachedQuestions = null;
    _lastFetchTime = null;
  }
}
