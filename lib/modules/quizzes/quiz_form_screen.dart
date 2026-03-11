import 'package:flutter/material.dart';

class QuizFormScreen extends StatefulWidget {
  final String? quizId;
  final String? courseId;

  const QuizFormScreen({Key? key, this.quizId, this.courseId})
    : super(key: key);

  @override
  State<QuizFormScreen> createState() => _QuizFormScreenState();
}

class _QuizFormScreenState extends State<QuizFormScreen> {
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.quizId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Quiz' : 'Create Quiz')),
      body: Center(
        child: Text(
          isEditing
              ? 'Editing Quiz: ${widget.quizId}'
              : 'Creating Quiz for Course: ${widget.courseId}',
        ),
      ),
    );
  }
}
