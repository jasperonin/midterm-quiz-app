import 'package:flutter/material.dart';
import '../../core/constants/app_enums.dart';

class AnalyticsScreen extends StatefulWidget {
  final String? courseId;

  const AnalyticsScreen({Key? key, this.courseId}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  ViewType _currentView = ViewType.lab;
  TimeRange _selectedRange = TimeRange.weekly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Navigate to export
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Analytics Screen - Course: ${widget.courseId}, View: $_currentView, Range: $_selectedRange',
        ),
      ),
    );
  }
}
