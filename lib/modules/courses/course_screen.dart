import 'package:flutter/material.dart';

class CoursesScreen extends StatefulWidget {
  final String? teacherId;

  const CoursesScreen({Key? key, this.teacherId}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create course
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Courses Screen - Teacher ID: ${widget.teacherId}'),
      ),
    );
  }
}
