// lib/modules/dashboard/widgets/dashboard_header.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';
import 'course_selector.dart';
import 'view_toggle.dart';
import 'time_range_selector.dart';

class DashboardHeader extends StatelessWidget {
  final String teacherId;
  final String? selectedCourseId;
  final ViewType currentView;
  final TimeRange selectedTimeRange;
  final Function(String?) onCourseChanged;
  final Function(ViewType) onViewChanged;
  final Function(TimeRange) onTimeRangeChanged;
  final VoidCallback onRefresh;

  const DashboardHeader({
    super.key,
    required this.teacherId,
    required this.selectedCourseId,
    required this.currentView,
    required this.selectedTimeRange,
    required this.onCourseChanged,
    required this.onViewChanged,
    required this.onTimeRangeChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Top Row - Course Selector and Refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Course Selector
              SizedBox(
                width: 300,
                child: CourseSelector(
                  teacherId: teacherId,
                  selectedCourseId: selectedCourseId,
                  onChanged: onCourseChanged,
                ),
              ),

              // Refresh Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                  tooltip: 'Refresh Dashboard',
                  splashRadius: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Bottom Row - Welcome, View Toggle, Time Range
          Row(
            children: [
              // Welcome Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Instructor',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // View Toggle
              ViewToggle(currentView: currentView, onChanged: onViewChanged),

              const SizedBox(width: 12),

              // Time Range Selector
              TimeRangeSelector(
                selectedRange: selectedTimeRange,
                onChanged: onTimeRangeChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
