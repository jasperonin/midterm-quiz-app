// lib/screens/teacher/teacher_main.dart
import 'package:app/modules/analytics/analytics_detailed.dart';
import 'package:app/modules/analytics/analytics_export_screen.dart';
import 'package:app/modules/courses/course_details.dart';
import 'package:app/modules/courses/course_form_screen.dart';
import 'package:app/modules/courses/course_screen.dart';
import 'package:app/modules/quizzes/quiz_screen.dart';
import 'package:app/modules/settings/profile_screen.dart';
import 'package:app/modules/settings/setting_general_screen.dart';
import 'package:app/modules/settings/setting_notifications_screen.dart';
import 'package:app/modules/settings/setting_security_screen.dart';
import 'package:app/modules/students/student_bulk_import_screen.dart';
import 'package:app/modules/students/student_form_screen.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart'; // Add this import
import 'package:app/modules/settings/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html; // For web platform detection
import '../../../firebase_options.dart';
import '../../modules/dashboard/dashboard_screen.dart';
import '../../modules/students/students_screen.dart';
import '../../modules/students/student_details_screen.dart';
import '../../modules/quizzes/quiz_details_screen.dart';
import '../../modules/quizzes/quiz_form_screen.dart';
import '../../modules/quizzes/quiz_results_screen.dart';
import '../../modules/analytics/analytics_screen.dart';
import '../../view/home.dart';
import '../../config/routes.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/quiz_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set URL strategy for web - clean URLs without #
  setUrlStrategy(PathUrlStrategy());

  // Add global error handler for Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    // Check if it's the scroll simulation error
    if (details.exception.toString().contains('scroll_simulation.dart:236')) {
      debugPrint('⚠️ Suppressed scroll simulation error');
      return; // Suppress this specific error
    }
    // For other errors, use default handler
    FlutterError.dumpErrorToConsole(details);
  };

  try {
    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    debugPrint('✅ Firebase initialized for Teacher Dashboard');
  } catch (e) {
    debugPrint('❌ Firebase init error: $e');
  }

  runApp(const TeacherApp());
}

class TeacherApp extends StatelessWidget {
  const TeacherApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bool isWeb = identical(0, 0.0);

    // Wrap the entire app with error handling
    final rootWidget = _buildAppWithProviders();

    if (isWeb) {
      return FlutterWebFrame(
        builder: (context) => ErrorBoundary(child: rootWidget),
        maximumSize: const Size(double.infinity, double.infinity),
        backgroundColor: Colors.grey.shade300,
        enabled: true,
      );
    }

    return ErrorBoundary(child: rootWidget);
  }

  Widget _buildAppWithProviders() {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<CourseRepository>(create: (_) => CourseRepository()),
        Provider<StudentRepository>(create: (_) => StudentRepository()),
        Provider<QuizRepository>(create: (_) => QuizRepository()),
        Provider<AnalyticsRepository>(create: (_) => AnalyticsRepository()),

        // Providers
        ChangeNotifierProvider<DashboardProvider>(
          create: (context) => DashboardProvider(
            analyticsRepo: context.read<AnalyticsRepository>(),
          ),
        ),
        ChangeNotifierProvider<CourseProvider>(
          create: (context) =>
              CourseProvider(repository: context.read<CourseRepository>()),
        ),
        ChangeNotifierProvider<StudentProvider>(
          create: (context) =>
              StudentProvider(repository: context.read<StudentRepository>()),
        ),
        ChangeNotifierProvider<QuizProvider>(
          create: (context) =>
              QuizProvider(repository: context.read<QuizRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Teacher Dashboard',
        initialRoute: AppRoutes.dashboard,
        onGenerateRoute: (settings) {
          debugPrint('🎯 onGenerateRoute called with: ${settings.name}');
          return MaterialPageRoute(
            builder: (context) => _buildRoute(settings, context),
            settings: settings, // Preserve the settings
          );
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  // Complete route generation in teacher_main.dart

  Widget _buildRoute(RouteSettings settings, BuildContext context) {
    debugPrint('🛣️ Building route: ${settings.name}');
    debugPrint('📦 Route settings: $settings');
    debugPrint('🎯 Route arguments: ${settings.arguments}');

    final uri = Uri.parse(settings.name ?? '');
    debugPrint('🔍 URI path: ${uri.path}');
    debugPrint('🔍 URI segments: ${uri.pathSegments}');
    final pathSegments = uri.pathSegments;

    // Handle student details route with path parameter (/student/:id)
    if (pathSegments.length == 2 && pathSegments[0] == 'student') {
      final studentId = pathSegments[1];
      final routeArgs = settings.arguments as Map<String, dynamic>? ?? {};

      debugPrint('📋 Parsed student ID from path: $studentId');
      return StudentDetailsScreen(
        studentId: studentId,
        teacherId: routeArgs['teacherId'] ?? 'teacher_123',
      );
    }

    // Handle course details route with path parameter (/courses/:id)
    if (pathSegments.length == 2 && pathSegments[0] == 'courses') {
      final courseId = pathSegments[1];
      return CourseDetailsScreen(courseId: courseId);
    }

    // Handle quiz details route with path parameter (/quizzes/:id)
    if (pathSegments.length == 2 && pathSegments[0] == 'quizzes') {
      final quizId = pathSegments[1];
      return QuizDetailsScreen(quizId: quizId);
    }

    // Handle quiz results route with path parameter (/quizzes/:id/results)
    if (pathSegments.length == 3 &&
        pathSegments[0] == 'quizzes' &&
        pathSegments[2] == 'results') {
      final quizId = pathSegments[1];
      return QuizResultsScreen(quizId: quizId);
    }

    // Regular named routes without path parameters
    switch (settings.name) {
      case AppRoutes.dashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        return DashboardScreen(
          teacherId: args?['teacherId'] ?? 'teacher_123',
          teacherName: args?['teacherName'] ?? 'Dr. Amancio',
        );

      case AppRoutes.quizzes:
        final args = settings.arguments as Map<String, dynamic>?;
        return QuizzesScreen(courseId: args?['courseId']);

      case AppRoutes.quizDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('quizId')) {
          return QuizDetailsScreen(quizId: args['quizId'] ?? '');
        }
        return _buildErrorScreen('Quiz ID required', context);

      case AppRoutes.quizCreate:
        final args = settings.arguments as Map<String, dynamic>?;
        return QuizFormScreen(courseId: args?['courseId']);

      case AppRoutes.quizResults:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('quizId')) {
          return QuizResultsScreen(quizId: args['quizId'] ?? '');
        }
        return _buildErrorScreen('Quiz ID required', context);

      case AppRoutes.students:
        final args = settings.arguments as Map<String, dynamic>?;
        return StudentsScreen(
          courseId: args?['courseId'],
          teacherId: args?['teacherId'],
        );

      case AppRoutes.studentDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('studentId')) {
          debugPrint('📋 Navigating to student details with args: $args');
          return StudentDetailsScreen(
            studentId: args['studentId'] ?? '',
            teacherId: args['teacherId'] ?? 'teacher_123',
          );
        }
        debugPrint('❌ Invalid args for student details: $args');
        return _buildErrorScreen('Student ID required', context);

      case AppRoutes.studentCreate:
        final args = settings.arguments as Map<String, dynamic>?;
        return StudentFormScreen(courseId: args?['courseId']);

      case AppRoutes.studentBulkImport:
        final args = settings.arguments as Map<String, dynamic>?;
        return StudentBulkImportScreen(courseId: args?['courseId']);

      case AppRoutes.analytics:
        final args = settings.arguments as Map<String, dynamic>?;
        return AnalyticsScreen(courseId: args?['courseId']);

      case AppRoutes.analyticsDetailed:
        final args = settings.arguments as Map<String, dynamic>?;
        return AnalyticsDetailedScreen(
          courseId: args?['courseId'],
          viewType: args?['viewType'],
        );

      case AppRoutes.analyticsExport:
        final args = settings.arguments as Map<String, dynamic>?;
        return AnalyticsExportScreen(courseId: args?['courseId']);

      case AppRoutes.settings:
        return const SettingsScreen();

      case AppRoutes.profile:
        final args = settings.arguments as Map<String, dynamic>?;
        return ProfileScreen(teacherId: args?['teacherId'] ?? '');

      case AppRoutes.settingsGeneral:
        return const SettingsGeneralScreen();

      case AppRoutes.settingsNotifications:
        return const SettingsNotificationsScreen();

      case AppRoutes.settingsSecurity:
        return const SettingsSecurityScreen();

      case AppRoutes.courses:
        final args = settings.arguments as Map<String, dynamic>?;
        return CoursesScreen(teacherId: args?['teacherId'] ?? '');

      case AppRoutes.courseCreate:
        final args = settings.arguments as Map<String, dynamic>?;
        return CourseFormScreen(teacherId: args?['teacherId'] ?? '');

      case AppRoutes.courseEdit:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('courseId')) {
          return CourseFormScreen(
            courseId: args['courseId'],
            teacherId: args['teacherId'] ?? '',
          );
        }
        return _buildErrorScreen('Course ID required', context);

      case AppRoutes.courseDetails:
        // This case is handled by path parameter above
        return _buildErrorScreen('Course ID required', context);

      case AppRoutes.home:
        return const HomeScreen();

      default:
        return _buildErrorScreen(
          'No route defined for ${settings.name}',
          context,
        );
    }
  }

  Widget _buildErrorScreen(String message, BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Error'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  navigatorKey.currentState?.pushNamedAndRemoveUntil(
                    AppRoutes.dashboard,
                    (route) => false,
                  );
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for error routes
  // Update the error route method to accept context
  // Route<dynamic> _errorRoute(String message, BuildContext context) {
  //   return MaterialPageRoute(
  //     builder: (_) => Scaffold(
  //       appBar: AppBar(
  //         title: const Text('Navigation Error'),
  //         backgroundColor: Colors.red,
  //       ),
  //       body: Center(
  //         child: Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
  //               const SizedBox(height: 16),
  //               Text(
  //                 message,
  //                 style: const TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //               const SizedBox(height: 24),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   // Navigate back to dashboard
  //                   Navigator.pushNamedAndRemoveUntil(
  //                     context, // Now context is available
  //                     AppRoutes.dashboard,
  //                     (route) => false,
  //                   );
  //                 },
  //                 child: const Text('Go to Dashboard'),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

// Error Boundary Widget
class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e, stack) {
          debugPrint('⚠️ Error caught in boundary: $e');
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The application encountered an error.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Reload the app
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.dashboard,
                          (route) => false,
                        );
                      },
                      child: const Text('Reload Dashboard'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
