// lib/config/routes.dart
class AppRoutes {
  // Authentication Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main Routes
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String courses = '/courses';
  static const String students = '/students';
  static const String quizzes = '/quizzes';
  static const String analytics = '/analytics';
  static const String settings = '/settings';

  // Course Management
  static const String courseDetails = '/courses/:id'; // Path pattern
  static const String courseCreate = '/courses/create';
  static const String courseEdit = '/courses/:id/edit';

  // Student Management
  static const String studentDetails = '/student/:id'; // Path pattern
  static const String studentCreate = '/students/create';
  static const String studentEdit = '/students/:id/edit';
  static const String studentBulkImport = '/students/import';

  // Quiz Management
  static const String quizDetails = '/quizzes/:id';
  static const String quizCreate = '/quizzes/create';
  static const String quizEdit = '/quizzes/:id/edit';
  static const String quizResults = '/quizzes/:id/results';

  // Analytics
  static const String analyticsDetailed = '/analytics/detailed';
  static const String analyticsExport = '/analytics/export';

  // Profile & Settings
  static const String profile = '/profile';
  static const String settingsGeneral = '/settings/general';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsSecurity = '/settings/security';
}

// Add this extension to routes.dart for easier path generation
extension RoutePath on AppRoutes {
  static String studentDetails(String id) => '/student/$id';
  static String courseDetails(String id) => '/courses/$id';
  static String quizDetails(String id) => '/quizzes/$id';
  static String quizResults(String id) => '/quizzes/$id/results';
}
