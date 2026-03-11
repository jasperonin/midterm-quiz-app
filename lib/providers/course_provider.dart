import 'package:app/models/course_model.dart';
import 'package:flutter/material.dart';
import '../data/repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository;
  List<CourseModel> _courses = [];
  bool _isLoading = false;
  String? _error;

  CourseProvider({required CourseRepository repository})
    : _repository = repository;

  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCourses(String teacherId) async {
    _setLoading(true);
    try {
      _courses = await _repository.getCoursesByTeacher(teacherId);
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
