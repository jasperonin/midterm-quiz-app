import 'package:flutter/material.dart';

class StudentFormScreen extends StatefulWidget {
  final String? studentId;
  final String? courseId;

  const StudentFormScreen({super.key, this.studentId, this.courseId});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.studentId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Student' : 'Add Student')),
      body: Center(
        child: Text(
          isEditing
              ? 'Editing Student: ${widget.studentId}'
              : 'Adding Student to Course: ${widget.courseId}',
        ),
      ),
    );
  }
}
