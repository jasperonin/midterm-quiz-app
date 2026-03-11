// lib/providers/dashboard_provider.dart
import 'package:app/models/course_model.dart';
import 'package:app/models/dashboard_data.dart';
import 'package:flutter/material.dart';
import '../data/repositories/analytics_repository.dart';
import '../core/constants/app_enums.dart';

class DashboardProvider extends ChangeNotifier {
  final AnalyticsRepository _analyticsRepo;

  // State
  String? _selectedCourseId;
  ViewType _currentView = ViewType.lab;
  TimeRange _selectedTimeRange = TimeRange.weekly;
  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _error;

  // Pagination for student list
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMoreData = true;

  DashboardProvider({required AnalyticsRepository analyticsRepo})
    : _analyticsRepo = analyticsRepo;

  // Getters
  String? get selectedCourseId => _selectedCourseId;
  ViewType get currentView => _currentView;
  TimeRange get selectedTimeRange => _selectedTimeRange;
  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

  // Computed getters
  List<CourseModel> get courses => _dashboardData?.courses ?? [];
  DashboardStats get stats => _dashboardData?.stats ?? DashboardStats.initial();
  List<PerformanceData> get performanceHistory =>
      _dashboardData?.performanceHistory ?? [];
  List<StudentPerformance> get topStudents => _dashboardData?.topStudents ?? [];
  List<RecentActivity> get recentActivities =>
      _dashboardData?.recentActivities ?? [];
  List<UpcomingQuiz> get upcomingQuizzes =>
      _dashboardData?.upcomingQuizzes ?? [];

  // Actions
  Future<void> loadDashboardData({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMoreData = true;
    }

    _setLoading(true);
    _clearError();

    try {
      final data = await _analyticsRepo.getDashboardData(
        courseId: _selectedCourseId,
        viewType: _currentView,
        timeRange: _selectedTimeRange,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (_currentPage == 0) {
        _dashboardData = data;
      } else {
        // Append more data for pagination
        _dashboardData = _dashboardData?.copyWith(
          topStudents: [...?_dashboardData?.topStudents, ...data.topStudents],
          recentActivities: [
            ...?_dashboardData?.recentActivities,
            ...data.recentActivities,
          ],
        );
      }

      _hasMoreData = data.topStudents.length >= _pageSize;
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading dashboard: $e');
    } finally {
      _setLoading(false);
    }
  }

  void selectCourse(String? courseId) {
    if (_selectedCourseId == courseId) return;

    _selectedCourseId = courseId;
    loadDashboardData(refresh: true);
  }

  void changeView(ViewType view) {
    if (_currentView == view) return;

    _currentView = view;
    loadDashboardData(refresh: true);
  }

  void changeTimeRange(TimeRange range) {
    if (_selectedTimeRange == range) return;

    _selectedTimeRange = range;
    loadDashboardData(refresh: true);
  }

  Future<void> loadMore() async {
    if (!_hasMoreData || _isLoading) return;

    _currentPage++;
    await loadDashboardData();
  }

  void refresh() {
    loadDashboardData(refresh: true);
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Extension for copyWith
extension DashboardDataCopy on DashboardData {
  DashboardData copyWith({
    List<CourseModel>? courses,
    DashboardStats? stats,
    List<PerformanceData>? performanceHistory,
    List<StudentPerformance>? topStudents,
    List<RecentActivity>? recentActivities,
    List<UpcomingQuiz>? upcomingQuizzes,
  }) {
    return DashboardData(
      courses: courses ?? this.courses,
      stats: stats ?? this.stats,
      performanceHistory: performanceHistory ?? this.performanceHistory,
      topStudents: topStudents ?? this.topStudents,
      recentActivities: recentActivities ?? this.recentActivities,
      upcomingQuizzes: upcomingQuizzes ?? this.upcomingQuizzes,
    );
  }
}
