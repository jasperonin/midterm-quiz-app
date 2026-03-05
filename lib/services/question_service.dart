// lib/services/question_service.dart (Simplified - no Question model)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connection_service.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectionService _connection = ConnectionService();

  // In-memory cache as List<Map>
  List<Map<String, dynamic>>? _cachedQuestions;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(hours: 1);
  static const String _quizId =
      'YOUR_QUIZ_ID'; // Replace with your actual quiz ID

  // Get 20 random questions with offline support
  Future<List<Map<String, dynamic>>> getQuizQuestions({
    int count = 20,
    bool forceRefresh = false,
  }) async {
    try {
      // Check if we have valid cache
      if (!forceRefresh && _hasValidCache()) {
        print('📦 Using cached questions (${_cachedQuestions!.length})');
        return _getRandomQuestions(_cachedQuestions!, count);
      }

      // Check internet connection
      bool hasInternet = await _connection.hasInternetConnection();

      DocumentSnapshot snapshot;

      if (hasInternet) {
        // Online: Fetch from Firestore
        print('🌐 Fetching questions from Firestore...');
        snapshot = await _firestore.collection('quizzes').doc(_quizId).get();

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          List<dynamic> questionsJson = data['questions'] ?? [];

          _cachedQuestions = questionsJson.map((q) {
            return Map<String, dynamic>.from(q);
          }).toList();

          _lastFetchTime = DateTime.now();
          print('✅ Cached ${_cachedQuestions!.length} questions');
        }
      } else {
        // Offline: Try to get from Firestore cache
        print('📴 Offline mode - attempting to load from cache...');
        try {
          snapshot = await _firestore
              .collection('quizzes')
              .doc(_quizId)
              .get(const GetOptions(source: Source.cache));

          if (snapshot.exists) {
            Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
            List<dynamic> questionsJson = data['questions'] ?? [];

            _cachedQuestions = questionsJson.map((q) {
              return Map<String, dynamic>.from(q);
            }).toList();

            print('✅ Loaded ${_cachedQuestions!.length} questions from cache');
          } else {
            throw Exception('No cached questions available');
          }
        } catch (e) {
          print('❌ No cache available: $e');
          throw Exception(
            'You need an internet connection to download questions first',
          );
        }
      }

      if (_cachedQuestions == null || _cachedQuestions!.isEmpty) {
        throw Exception('No questions available');
      }

      // Return random selection
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
    List<Map<String, dynamic>> shuffled = List.from(allQuestions);
    shuffled.shuffle();
    return shuffled.take(count).toList();
  }

  // Helper to get correct answer index from choices
  int getCorrectAnswerIndex(Map<String, dynamic> question) {
    List<dynamic> choices = question['choices'] ?? [];
    for (int i = 0; i < choices.length; i++) {
      if (choices[i]['isCorrect'] == true) return i;
    }
    return 0;
  }

  // Helper to get options as list of strings
  List<String> getOptions(Map<String, dynamic> question) {
    List<dynamic> choices = question['choices'] ?? [];
    return choices.map((c) => c['text'].toString()).toList();
  }

  // Clear cache if needed
  void clearCache() {
    _cachedQuestions = null;
    _lastFetchTime = null;
  }
}
