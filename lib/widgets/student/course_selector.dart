// lib/widgets/student/course_selector.dart
import 'package:flutter/material.dart';

class CourseSelector extends StatelessWidget {
  final String selectedCourse;
  final void Function(String) onCourseSelected;

  const CourseSelector({
    super.key,
    required this.selectedCourse,
    required this.onCourseSelected,
  });

  @override
  Widget build(BuildContext context) {
    final activeStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.teal.shade800,
    );
    final inactiveStyle = TextStyle(
      fontWeight: FontWeight.normal,
      color: Colors.grey.shade600,
    );

    return Row(
      children: [
        const Text(
          '📚 Course Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Spacer(),

        TextButton(
          onPressed: () => onCourseSelected('lecture'),
          child: Text(
            'Lecture',
            style: selectedCourse == 'lecture' ? activeStyle : inactiveStyle,
          ),
        ),

        const SizedBox(width: 8),

        TextButton(
          onPressed: () => onCourseSelected('lab'),
          child: Text(
            'Lab',
            style: selectedCourse == 'lab' ? activeStyle : inactiveStyle,
          ),
        ),
      ],
    );
  }
}
