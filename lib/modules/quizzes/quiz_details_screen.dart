import 'package:flutter/material.dart';

class QuizDetailsScreen extends StatefulWidget {
  final String quizId;

  const QuizDetailsScreen({Key? key, required this.quizId}) : super(key: key);

  @override
  State<QuizDetailsScreen> createState() => _QuizDetailsScreenState();
}

class _QuizDetailsScreenState extends State<QuizDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              // Navigate to quiz results
            },
          ),
        ],
      ),
      body: Center(child: Text('Quiz Details - ID: ${widget.quizId}')),
    );
  }
}
