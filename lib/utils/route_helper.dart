// lib/core/utils/route_helper.dart
import '../config/routes.dart';

class RouteHelper {
  // Generate student details path
  static String studentDetails(String studentId) {
    return '/student/$studentId';
  }
  
  // Generate course details path
  static String courseDetails(String courseId) {
    return '/courses/$courseId';
  }
  
  // Generate quiz details path
  static String quizDetails(String quizId) {
    return '/quizzes/$quizId';
  }
  
  // Generate quiz results path
  static String quizResults(String quizId) {
    return '/quizzes/$quizId/results';
  }
  
  // Extract ID from path
  static String? extractIdFromPath(String path, String prefix) {
    final uri = Uri.parse(path);
    final segments = uri.pathSegments;
    
    if (segments.length >= 2 && segments[0] == prefix) {
      return segments[1];
    }
    return null;
  }
}