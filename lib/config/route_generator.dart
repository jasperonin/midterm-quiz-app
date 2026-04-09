// lib/config/route_generator.dart
import 'package:app/modules/analytics/analytics_detailed.dart';
import 'package:app/modules/courses/course_details.dart';
import 'package:app/modules/courses/course_screen.dart';
import 'package:app/modules/quizzes/quiz_screen.dart';
import 'package:app/modules/settings/setting_general_screen.dart';
import 'package:app/modules/settings/setting_notifications_screen.dart';
import 'package:app/modules/settings/setting_screen.dart';
import 'package:app/modules/settings/setting_security_screen.dart';
import 'package:app/modules/students/student_details_screen.dart';
import '../screens/teacher/academic_calendar_screen.dart';
import 'package:flutter/material.dart';
import '../modules/dashboard/dashboard_screen.dart';
import '../modules/courses/course_form_screen.dart';
import '../modules/students/students_screen.dart';
import '../modules/students/student_form_screen.dart';
import '../modules/students/student_bulk_import_screen.dart';
import '../modules/quizzes/quiz_details_screen.dart';
import '../modules/quizzes/quiz_form_screen.dart';
import '../modules/quizzes/quiz_results_screen.dart';
import '../modules/analytics/analytics_screen.dart';
import '../modules/analytics/analytics_export_screen.dart';

import '../modules/settings/profile_screen.dart';

import 'routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Get arguments
    final args = settings.arguments;

    switch (settings.name) {
      // Home
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(teacherId: '', teacherName: ''),
        );

      // Dashboard
      case AppRoutes.dashboard:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => DashboardScreen(
              teacherId: args['teacherId'] ?? '',
              teacherName: args['teacherName'] ?? 'Instructor',
            ),
          );
        }
        return _errorRoute('Dashboard requires teacher ID');

      // Courses
      case AppRoutes.courses:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => CoursesScreen(teacherId: args['teacherId'] ?? ''),
          );
        }
        return MaterialPageRoute(builder: (_) => const CoursesScreen());

      case AppRoutes.courseDetails:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) =>
                CourseDetailsScreen(courseId: args['courseId'] ?? ''),
          );
        }
        return _errorRoute('Course ID required');

      case AppRoutes.courseCreate:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) =>
                CourseFormScreen(teacherId: args['teacherId'] ?? ''),
          );
        }
        return MaterialPageRoute(builder: (_) => const CourseFormScreen());

      case AppRoutes.courseEdit:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => CourseFormScreen(
              courseId: args['courseId'],
              teacherId: args['teacherId'] ?? '',
            ),
          );
        }
        return _errorRoute('Course ID required');

      // Students
      case AppRoutes.students:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => StudentsScreen(
              courseId: args['courseId'],
              teacherId: args['teacherId'] ?? '',
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const StudentsScreen());

      case AppRoutes.studentDetails:
        // Extract studentId from the path pattern
        // You likely have a function that parses the URI
        final uri = Uri.parse(settings.name!);
        final segments = uri.pathSegments;

        // If the route is '/student/5250531', segments = ['student', '5250531']
        final studentId = segments.length > 1 ? segments[1] : null;

        // Or if you're passing arguments directly
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (context) => StudentDetailsScreen(
            studentId: args?['studentId'] ?? studentId ?? '',
            teacherId: args?['teacherId'] ?? '',
          ),
        );

      case AppRoutes.studentCreate:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => StudentFormScreen(courseId: args['courseId']),
          );
        }
        return MaterialPageRoute(builder: (_) => const StudentFormScreen());

      case AppRoutes.studentEdit:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => StudentFormScreen(
              studentId: args['studentId'],
              courseId: args['courseId'],
            ),
          );
        }
        return _errorRoute('Student ID required');

      case AppRoutes.studentBulkImport:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => StudentBulkImportScreen(courseId: args['courseId']),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const StudentBulkImportScreen(),
        );

      // Quizzes
      case AppRoutes.quizzes:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => QuizzesScreen(courseId: args['courseId']),
          );
        }
        return MaterialPageRoute(builder: (_) => const QuizzesScreen());

      case AppRoutes.quizDetails:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => QuizDetailsScreen(quizId: args['quizId'] ?? ''),
          );
        }
        return _errorRoute('Quiz ID required');

      case AppRoutes.quizCreate:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => QuizFormScreen(courseId: args['courseId']),
          );
        }
        return MaterialPageRoute(builder: (_) => const QuizFormScreen());

      case AppRoutes.quizEdit:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => QuizFormScreen(
              quizId: args['quizId'],
              courseId: args['courseId'],
            ),
          );
        }
        return _errorRoute('Quiz ID required');

      case AppRoutes.quizResults:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => QuizResultsScreen(quizId: args['quizId'] ?? ''),
          );
        }
        return _errorRoute('Quiz ID required');

      // Analytics
      case AppRoutes.analytics:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => AnalyticsScreen(courseId: args['courseId']),
          );
        }
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());

      case AppRoutes.analyticsDetailed:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => AnalyticsDetailedScreen(
              courseId: args['courseId'],
              viewType: args['viewType'],
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const AnalyticsDetailedScreen(),
        );

      case AppRoutes.analyticsExport:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => AnalyticsExportScreen(courseId: args['courseId']),
          );
        }
        return MaterialPageRoute(builder: (_) => const AnalyticsExportScreen());

      // Settings
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case AppRoutes.profile:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ProfileScreen(teacherId: args['teacherId'] ?? ''),
          );
        }
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppRoutes.settingsGeneral:
        return MaterialPageRoute(builder: (_) => const SettingsGeneralScreen());

      case AppRoutes.settingsNotifications:
        return MaterialPageRoute(
          builder: (_) => const SettingsNotificationsScreen(),
        );

      case AppRoutes.settingsSecurity:
        return MaterialPageRoute(
          builder: (_) => const SettingsSecurityScreen(),
        );

      case AppRoutes.academicCalendar:
        return MaterialPageRoute(
          builder: (_) => const AcademicCalendarScreen(),
        );

      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text(message)),
        );
      },
    );
  }
}
