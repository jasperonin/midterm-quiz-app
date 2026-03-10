// lib/screens/teacher/grading_tab.dart
import 'package:flutter/material.dart';

class GradingTab extends StatefulWidget {
  const GradingTab({Key? key}) : super(key: key);

  @override
  _GradingTabState createState() => _GradingTabState();
}

class _GradingTabState extends State<GradingTab> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Grading Tab - Will be populated with coding exam submissions'),
    );
  }
}