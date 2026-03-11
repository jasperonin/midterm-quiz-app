import 'package:app/models/student_model.dart';
import 'package:flutter/material.dart';
import '../data/repositories/student_repository.dart';

class StudentProvider extends ChangeNotifier {
  final StudentRepository _repository;
  List<StudentModel> _students = [];
  bool _isLoading = false;
  String? _error;

  StudentProvider({required StudentRepository repository})
    : _repository = repository;

  List<StudentModel> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStudentsByCourse(String courseId) async {
    _setLoading(true);
    try {
      _students = await _repository.getStudentsByCourse(courseId);
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
