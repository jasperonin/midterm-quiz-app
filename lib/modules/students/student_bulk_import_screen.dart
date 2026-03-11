import 'package:flutter/material.dart';

class StudentBulkImportScreen extends StatefulWidget {
  final String? courseId;

  const StudentBulkImportScreen({Key? key, this.courseId}) : super(key: key);

  @override
  State<StudentBulkImportScreen> createState() =>
      _StudentBulkImportScreenState();
}

class _StudentBulkImportScreenState extends State<StudentBulkImportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Import Students')),
      body: Center(
        child: Text('Bulk Import Students - Course: ${widget.courseId}'),
      ),
    );
  }
}
