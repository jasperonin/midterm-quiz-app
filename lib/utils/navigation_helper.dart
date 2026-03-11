// lib/shared/utils/navigation_helper.dart
import 'package:flutter/material.dart';
import '../../config/routes.dart';

class NavigationHelper {
  static void goToDashboard(
    BuildContext context, {
    required String teacherId,
    required String teacherName,
  }) {
    Navigator.pushNamed(
      context,
      AppRoutes.dashboard,
      arguments: {'teacherId': teacherId, 'teacherName': teacherName},
    );
  }

  static void goToQuizzes(BuildContext context, {String? courseId}) {
    Navigator.pushNamed(
      context,
      AppRoutes.quizzes,
      arguments: {'courseId': courseId},
    );
  }

  static void goToStudents(BuildContext context, {String? courseId}) {
    Navigator.pushNamed(
      context,
      AppRoutes.students,
      arguments: {'courseId': courseId},
    );
  }

  static void goToAnalytics(BuildContext context, {String? courseId}) {
    Navigator.pushNamed(
      context,
      AppRoutes.analytics,
      arguments: {'courseId': courseId},
    );
  }

  static void goToSettings(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  static void goToCourses(BuildContext context, {String? teacherId}) {
    Navigator.pushNamed(
      context,
      AppRoutes.courses,
      arguments: {'teacherId': teacherId},
    );
  }

  static void goToCourseDetails(BuildContext context, String courseId) {
    Navigator.pushNamed(
      context,
      AppRoutes.courseDetails,
      arguments: {'courseId': courseId},
    );
  }

  static void goToCreateCourse(BuildContext context, String teacherId) {
    Navigator.pushNamed(
      context,
      AppRoutes.courseCreate,
      arguments: {'teacherId': teacherId},
    );
  }

  static void goToStudentDetails(BuildContext context, String studentId) {
    Navigator.pushNamed(
      context,
      AppRoutes.studentDetails,
      arguments: {'studentId': studentId},
    );
  }

  static void goToCreateStudent(BuildContext context, {String? courseId}) {
    Navigator.pushNamed(
      context,
      AppRoutes.studentCreate,
      arguments: {'courseId': courseId},
    );
  }

  static void goToQuizDetails(BuildContext context, String quizId) {
    Navigator.pushNamed(
      context,
      AppRoutes.quizDetails,
      arguments: {'quizId': quizId},
    );
  }

  static void goToCreateQuiz(BuildContext context, {String? courseId}) {
    Navigator.pushNamed(
      context,
      AppRoutes.quizCreate,
      arguments: {'courseId': courseId},
    );
  }

  static void goToQuizResults(BuildContext context, String quizId) {
    Navigator.pushNamed(
      context,
      AppRoutes.quizResults,
      arguments: {'quizId': quizId},
    );
  }

  static void goToProfile(BuildContext context, String teacherId) {
    Navigator.pushNamed(
      context,
      AppRoutes.profile,
      arguments: {'teacherId': teacherId},
    );
  }
}
