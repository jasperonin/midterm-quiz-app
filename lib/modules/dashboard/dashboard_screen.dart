// lib/modules/dashboard/dashboard_screen.dart
import 'package:app/widgets/dashboard/dashboard_header.dart';
import 'package:app/widgets/layouts/sidebar_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../data/repositories/analytics_repository.dart';


class DashboardScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;

  const DashboardScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardProvider _dashboardProvider;

  @override
  void initState() {
    super.initState();
    _dashboardProvider = DashboardProvider(
      analyticsRepo: AnalyticsRepository(),
    );

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dashboardProvider.loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _dashboardProvider,
      child: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            body: SidebarLayout(
              teacherId: widget.teacherId,
              teacherName: widget.teacherName,
              currentRoute: '/dashboard',
              child: _buildMainContent(provider),
            ),
          );
        },
      ),
    );
  }

  // In dashboard_screen.dart, replace _buildMainContent with:

  Widget _buildMainContent(DashboardProvider provider) {
    if (provider.isLoading && provider.dashboardData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          DashboardHeader(
            teacherId: widget.teacherId,
            selectedCourseId: provider.selectedCourseId,
            currentView: provider.currentView,
            selectedTimeRange: provider.selectedTimeRange,
            onCourseChanged: provider.selectCourse,
            onViewChanged: provider.changeView,
            onTimeRangeChanged: provider.changeTimeRange,
            onRefresh: provider.refresh,
          ),

          const SizedBox(height: 24),

          // Simple Stats Row
          Row(
            children: [
              Expanded(
                child: _buildSimpleStatCard(
                  'Total Students',
                  '48',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSimpleStatCard(
                  'Average Score',
                  '82%',
                  Icons.analytics,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSimpleStatCard(
                  'Completion Rate',
                  '94%',
                  Icons.check_circle,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSimpleStatCard(
                  'Active Sessions',
                  '3',
                  Icons.timer,
                  Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Simple placeholder
          Container(
            height: 200,
            color: Colors.grey.shade200,
            child: const Center(child: Text('Dashboard Content')),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
