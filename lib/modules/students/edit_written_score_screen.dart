import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditWrittenScoreScreen extends StatefulWidget {
  final String studentId;
  final String selectedPeriod;
  final int? currentScore;
  final int maxScore;

  const EditWrittenScoreScreen({
    super.key,
    required this.studentId,
    required this.selectedPeriod,
    required this.currentScore,
    required this.maxScore,
  });

  @override
  State<EditWrittenScoreScreen> createState() => _EditWrittenScoreScreenState();
}

class _EditWrittenScoreScreenState extends State<EditWrittenScoreScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _scoreController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController(
      text: widget.currentScore?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final scoreText = _scoreController.text.trim();
    final score = int.tryParse(scoreText);

    if (score == null || score < 0 || score > widget.maxScore) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter a valid score (0-${widget.maxScore})'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestore.collection('users').doc(widget.studentId).update({
        'writtenScore': score,
        'writtenScoreUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating written score: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Written Score'),
        backgroundColor: Colors.teal,
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _save,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Written Exam Score',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Period: ${widget.selectedPeriod}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _scoreController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Score',
                hintText: 'Enter score (0-${widget.maxScore})',
                border: const OutlineInputBorder(),
                suffixText: '/ ${widget.maxScore}',
              ),
              enabled: !_isSaving,
            ),
            const SizedBox(height: 24),
            if (_isSaving)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Score'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
