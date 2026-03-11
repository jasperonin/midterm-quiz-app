import 'package:flutter/material.dart';

class QuizResultsScreen extends StatefulWidget {
  final String quizId;

  const QuizResultsScreen({Key? key, required this.quizId}) : super(key: key);

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Export results
            },
          ),
        ],
      ),
      body: Center(child: Text('Quiz Results - Quiz ID: ${widget.quizId}')),
    );
  }
}
