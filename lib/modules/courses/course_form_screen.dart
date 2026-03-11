import 'package:flutter/material.dart';

class CourseFormScreen extends StatefulWidget {
  final String? courseId;
  final String? teacherId;

  const CourseFormScreen({Key? key, this.courseId, this.teacherId})
    : super(key: key);

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.courseId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Course' : 'Create Course')),
      body: Center(
        child: Text(
          isEditing
              ? 'Editing Course: ${widget.courseId}'
              : 'Creating New Course for Teacher: ${widget.teacherId}',
        ),
      ),
    );
  }
}
