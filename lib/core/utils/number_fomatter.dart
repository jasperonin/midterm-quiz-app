// lib/core/utils/number_formatter.dart
class NumberFormatter {
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  static String formatScore(int correct, int total) {
    return '$correct/$total';
  }

  static String formatTime(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    }
    
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes < 60) {
      return remainingSeconds > 0 
          ? '$minutes min $remainingSeconds sec'
          : '$minutes min';
    }
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (remainingMinutes > 0) {
      return '$hours hr $remainingMinutes min';
    }
    
    return '$hours hr';
  }

  static String formatCompactTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    
    return '0:${seconds.toString().padLeft(2, '0')}';
  }

  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  static String formatDecimal(double value, {int decimals = 1}) {
    return value.toStringAsFixed(decimals);
  }

  static String formatTrend(double value) {
    if (value > 0) {
      return '+${value.toStringAsFixed(1)}%';
    } else if (value < 0) {
      return '${value.toStringAsFixed(1)}%';
    }
    return '0%';
  }
}