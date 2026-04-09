import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProjectScreen extends StatefulWidget {
  final String studentId;
  final String selectedPeriod;
  final Map<String, dynamic>? projectData;

  const EditProjectScreen({
    super.key,
    required this.studentId,
    required this.selectedPeriod,
    this.projectData,
  });

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final TextEditingController _titleController;
  late final TextEditingController _dateController;
  late final TextEditingController _scoreController;
  late final TextEditingController _totalController;
  late final TextEditingController _feedbackController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.projectData?['title']?.toString() ?? '',
    );
    _dateController = TextEditingController(
      text: _formatDate(_parseDate(widget.projectData?['date'])),
    );
    _scoreController = TextEditingController(
      text: '${widget.projectData?['score'] ?? 0}',
    );
    _totalController = TextEditingController(
      text: '${widget.projectData?['totalPoints'] ?? 100}',
    );
    _feedbackController = TextEditingController(
      text: widget.projectData?['feedback']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _scoreController.dispose();
    _totalController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Future<void> _save() async {
    final date = DateTime.tryParse(_dateController.text.trim());
    final score = int.tryParse(_scoreController.text.trim());
    final totalPoints = int.tryParse(_totalController.text.trim());

    if (date == null ||
        score == null ||
        totalPoints == null ||
        totalPoints <= 0 ||
        score < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid date, score, and total'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestore.collection('users').doc(widget.studentId).set({
        'project': {
          widget.selectedPeriod: {
            'title': _titleController.text.trim(),
            'date': Timestamp.fromDate(date),
            'score': score,
            'totalPoints': totalPoints,
            'feedback': _feedbackController.text.trim(),
          },
        },
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating project: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(
              labelText: 'Date',
              hintText: 'YYYY-MM-DD',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _scoreController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Score'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _totalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Total'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _feedbackController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Feedback'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ),
        ),
      ),
    );
  }
}
