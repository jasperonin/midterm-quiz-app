// lib/data/models/dashboard_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_enums.dart';
import 'course_model.dart';

// Main Dashboard Data Class
class DashboardData {
  final List<CourseModel> courses;
  final DashboardStats stats;
  final List<PerformanceData> performanceHistory;
  final List<StudentPerformance> topStudents;
  final List<RecentActivity> recentActivities;
  final List<UpcomingQuiz> upcomingQuizzes;

  DashboardData({
    required this.courses,
    required this.stats,
    required this.performanceHistory,
    required this.topStudents,
    required this.recentActivities,
    required this.upcomingQuizzes,
  });

  factory DashboardData.initial() {
    return DashboardData(
      courses: [],
      stats: DashboardStats.initial(),
      performanceHistory: [],
      topStudents: [],
      recentActivities: [],
      upcomingQuizzes: [],
    );
  }
}

// Stats Class
class DashboardStats {
  final int totalStudents;
  final double averageScore;
  final double completionRate;
  final int activeSessions;
  final Map<String, dynamic> trends;

  DashboardStats({
    required this.totalStudents,
    required this.averageScore,
    required this.completionRate,
    required this.activeSessions,
    required this.trends,
  });

  factory DashboardStats.initial() {
    return DashboardStats(
      totalStudents: 0,
      averageScore: 0.0,
      completionRate: 0.0,
      activeSessions: 0,
      trends: {},
    );
  }

  factory DashboardStats.fromMap(Map<String, dynamic> map) {
    return DashboardStats(
      totalStudents: map['totalStudents'] ?? 0,
      averageScore: (map['averageScore'] ?? 0).toDouble(),
      completionRate: (map['completionRate'] ?? 0).toDouble(),
      activeSessions: map['activeSessions'] ?? 0,
      trends: map['trends'] ?? {},
    );
  }
}

// Performance Data Class
class PerformanceData {
  final DateTime date;
  final double labScore;
  final double lectureScore;
  final int submissions;

  PerformanceData({
    required this.date,
    required this.labScore,
    required this.lectureScore,
    required this.submissions,
  });

  factory PerformanceData.fromMap(Map<String, dynamic> map) {
    return PerformanceData(
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      labScore: (map['labScore'] ?? 0).toDouble(),
      lectureScore: (map['lectureScore'] ?? 0).toDouble(),
      submissions: map['submissions'] ?? 0,
    );
  }
}

// Student Performance Class
class StudentPerformance {
  final String studentId;
  final String studentName;
  final double averageScore;
  final int quizzesTaken;
  final StudentStatus status;

  StudentPerformance({
    required this.studentId,
    required this.studentName,
    required this.averageScore,
    required this.quizzesTaken,
    required this.status,
  });

  factory StudentPerformance.fromMap(Map<String, dynamic> map) {
    return StudentPerformance(
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      averageScore: (map['averageScore'] ?? 0).toDouble(),
      quizzesTaken: map['quizzesTaken'] ?? 0,
      status: _parseStatus(map['status']),
    );
  }

  static StudentStatus _parseStatus(dynamic status) {
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'active':
          return StudentStatus.active;
        case 'inactive':
          return StudentStatus.inactive;
        case 'atrisk':
        case 'at_risk':
          return StudentStatus.atRisk;
      }
    }
    return StudentStatus.active;
  }
}

// Recent Activity Class
class RecentActivity {
  final String id;
  final String studentName;
  final String activityType;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  RecentActivity({
    required this.id,
    required this.studentName,
    required this.activityType,
    required this.description,
    required this.timestamp,
    required this.metadata,
  });

  factory RecentActivity.fromMap(Map<String, dynamic> map, String docId) {
    return RecentActivity(
      id: docId,
      studentName: map['studentName'] ?? '',
      activityType: map['activityType'] ?? '',
      description: map['description'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: map['metadata'] ?? {},
    );
  }
}

// Upcoming Quiz Class
class UpcomingQuiz {
  final String id;
  final String title;
  final DateTime scheduledDate;
  final int totalStudents;
  final int completedCount;

  UpcomingQuiz({
    required this.id,
    required this.title,
    required this.scheduledDate,
    required this.totalStudents,
    required this.completedCount,
  });

  factory UpcomingQuiz.fromMap(Map<String, dynamic> map, String docId) {
    return UpcomingQuiz(
      id: docId,
      title: map['title'] ?? '',
      scheduledDate: (map['scheduledDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalStudents: map['totalStudents'] ?? 0,
      completedCount: map['completedCount'] ?? 0,
    );
  }

  double get completionPercentage {
    if (totalStudents == 0) return 0;
    return (completedCount / totalStudents) * 100;
  }
}

// Import for CourseModel - will be defined next
