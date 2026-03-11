// lib/modules/dashboard/widgets/stats_grid.dart
import 'package:flutter/material.dart';
import '../../models/dashboard_data.dart';
import '../cards/stat_card.dart';

class StatsGrid extends StatelessWidget {
  final DashboardStats stats;

  const StatsGrid({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2,
        children: [
          StatCard(
            title: 'Total Students',
            value: stats.totalStudents.toString(),
            icon: Icons.people,
            color: Colors.blue,
            trend: stats.trends['students']?.toString(),
            isPositive: _isPositiveTrend(stats.trends['students']),
          ),
          StatCard(
            title: 'Average Score',
            value: '${stats.averageScore.toStringAsFixed(1)}%',
            icon: Icons.analytics,
            color: Colors.green,
            trend: stats.trends['score']?.toString(),
            isPositive: _isPositiveTrend(stats.trends['score']),
          ),
          StatCard(
            title: 'Completion Rate',
            value: '${stats.completionRate.toStringAsFixed(1)}%',
            icon: Icons.check_circle,
            color: Colors.orange,
            trend: stats.trends['completion']?.toString(),
            isPositive: _isPositiveTrend(stats.trends['completion']),
          ),
          StatCard(
            title: 'Active Sessions',
            value: stats.activeSessions.toString(),
            icon: Icons.timer,
            color: Colors.purple,
            trend: stats.trends['sessions']?.toString(),
            isPositive: _isPositiveTrend(stats.trends['sessions']),
          ),
        ],
      ),
    );
  }

  bool _isPositiveTrend(dynamic trend) {
    if (trend == null) return true;
    final trendStr = trend.toString();
    return !trendStr.startsWith('-');
  }
}
