// lib/screens/major_exam/coding_section.dart
import 'package:flutter/material.dart';

class CodingSection extends StatefulWidget {
  final String studentId;
  final String studentName;
  final Function(int) onComplete;

  const CodingSection({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.onComplete,
  });

  @override
  _CodingSectionState createState() => _CodingSectionState();
}

class _CodingSectionState extends State<CodingSection> {
  
  // Placeholder coding problems
  final List<Map<String, dynamic>> _problems = [
    {
      'title': 'Problem 1: FizzBuzz',
      'description': 'Write a function that prints numbers 1 to 100...',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coding Problems',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Solve the following problems. You may switch tabs freely.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ..._problems.map((problem) {
            return Card(
              child: ListTile(
                title: Text(problem['title']),
                subtitle: Text(problem['description']),
                trailing: const Icon(Icons.code),
                onTap: () {
                  // Open coding problem
                },
              ),
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // For demo, complete with random score
              widget.onComplete(85);
            },
            child: const Text('Submit Coding Section'),
          ),
        ],
      ),
    );
  }
}