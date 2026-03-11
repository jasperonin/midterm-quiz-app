import 'package:flutter/material.dart';

class AnalyticsExportScreen extends StatefulWidget {
  final String? courseId;

  const AnalyticsExportScreen({Key? key, this.courseId}) : super(key: key);

  @override
  State<AnalyticsExportScreen> createState() => _AnalyticsExportScreenState();
}

class _AnalyticsExportScreenState extends State<AnalyticsExportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Analytics'),
      ),
      body: Center(
        child: Text('Export Analytics - Course: ${widget.courseId}'),
      ),
    );
  }
}