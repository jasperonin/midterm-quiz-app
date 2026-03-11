// lib/core/utils/date_formatter.dart
import 'package:intl/intl.dart';
import '../constants/app_enums.dart';

class DateFormatter {
  static String formatTimeRange(TimeRange range, DateTime date) {
    switch (range) {
      case TimeRange.today:
        return DateFormat('HH:mm').format(date);
      case TimeRange.weekly:
        return DateFormat('EEE').format(date);
      case TimeRange.monthly:
        return DateFormat('MMM d').format(date);
    }
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  static String formatDate(DateTime date, {String format = 'MMM d, yyyy'}) {
    return DateFormat(format).format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  static String formatTimeOfDay(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String getDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static String getMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  // Get range of dates based on time range
  static List<DateTime> getDateRange(TimeRange range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (range) {
      case TimeRange.today:
        return [today, today];

      case TimeRange.weekly:
        final start = today.subtract(Duration(days: today.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return [start, end];

      case TimeRange.monthly:
        final start = DateTime(today.year, today.month, 1);
        final end = DateTime(today.year, today.month + 1, 0);
        return [start, end];
    }
  }
}
