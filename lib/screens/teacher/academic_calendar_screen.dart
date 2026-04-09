// lib/screens/teacher/academic_calendar_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/academic_calendar/academic_calendar_settings.dart';

class AcademicCalendarScreen extends StatelessWidget {
  const AcademicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Calendar'),
        backgroundColor: Colors.teal,
      ),
      body: const AcademicCalendarSettings(),
    );
  }
}
