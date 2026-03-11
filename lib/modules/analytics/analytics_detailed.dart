import 'package:flutter/material.dart';
import '../../core/constants/app_enums.dart';

class AnalyticsDetailedScreen extends StatefulWidget {
  final String? courseId;
  final ViewType? viewType;

  const AnalyticsDetailedScreen({Key? key, this.courseId, this.viewType})
    : super(key: key);

  @override
  State<AnalyticsDetailedScreen> createState() =>
      _AnalyticsDetailedScreenState();
}

class _AnalyticsDetailedScreenState extends State<AnalyticsDetailedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detailed Analytics')),
      body: Center(
        child: Text(
          'Detailed Analytics - Course: ${widget.courseId}, View: ${widget.viewType}',
        ),
      ),
    );
  }
}
