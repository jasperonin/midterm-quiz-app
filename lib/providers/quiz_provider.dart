import 'package:app/models/quiz_data.dart';
import 'package:flutter/material.dart';
import '../data/repositories/quiz_repository.dart';

class QuizProvider extends ChangeNotifier {
  final QuizRepository _repository;
  List<QuizData> _quizzes = [];
  bool _isLoading = false;
  String? _error;

  QuizProvider({required QuizRepository repository})
      : _repository = repository;

  List<QuizData> get quizzes => _quizzes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadQuizzesByCourse(String courseId) async {
    _setLoading(true);
    try {
      _quizzes = await _repository.getQuizzesByCourse(courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}