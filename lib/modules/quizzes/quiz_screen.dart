import 'package:flutter/material.dart';

class QuizzesScreen extends StatefulWidget {
  final String? courseId;

  const QuizzesScreen({Key? key, this.courseId}) : super(key: key);

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create quiz
            },
          ),
        ],
      ),
      body: Center(child: Text('Quizzes Screen - Course: ${widget.courseId}')),
    );
  }
}
