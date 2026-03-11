// lib/core/constants/app_enums.dart
enum ViewType { lab, lecture }

enum TimeRange { today, weekly, monthly }

enum StudentStatus { active, inactive, atRisk }

enum QuizType { regular, major, practice }

enum DifficultyLevel { easy, medium, hard }

// Add extension for display names
extension ViewTypeExtension on ViewType {
  String get displayName {
    switch (this) {
      case ViewType.lab:
        return 'Lab';
      case ViewType.lecture:
        return 'Lecture';
    }
  }
}

extension TimeRangeExtension on TimeRange {
  String get displayName {
    switch (this) {
      case TimeRange.today:
        return 'Today';
      case TimeRange.weekly:
        return 'Weekly';
      case TimeRange.monthly:
        return 'Monthly';
    }
  }
}

extension StudentStatusExtension on StudentStatus {
  String get displayName {
    switch (this) {
      case StudentStatus.active:
        return 'Active';
      case StudentStatus.inactive:
        return 'Inactive';
      case StudentStatus.atRisk:
        return 'At Risk';
    }
  }
}
