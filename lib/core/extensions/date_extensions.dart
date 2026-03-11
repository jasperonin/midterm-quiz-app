// lib/core/extensions/date_extensions.dart
import '../constants/app_enums.dart';

extension DateRangeExtension on TimeRange {
  DateTime get startDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case TimeRange.today:
        return today;
      case TimeRange.weekly:
        return today.subtract(Duration(days: today.weekday - 1));
      case TimeRange.monthly:
        return DateTime(today.year, today.month, 1);
    }
  }

  DateTime get endDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case TimeRange.today:
        return today;
      case TimeRange.weekly:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return start.add(const Duration(days: 6));
      case TimeRange.monthly:
        return DateTime(today.year, today.month + 1, 0);
    }
  }

  String get displayName {
    switch (this) {
      case TimeRange.today:
        return 'Today';
      case TimeRange.weekly:
        return 'This Week';
      case TimeRange.monthly:
        return 'This Month';
    }
  }
}
