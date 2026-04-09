import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditGradedOralScreen extends StatefulWidget {
  final String studentId;
  final String selectedPeriod;
  final Map<String, dynamic>? oralData;

  const EditGradedOralScreen({
    super.key,
    required this.studentId,
    required this.selectedPeriod,
    this.oralData,
  });

  @override
  State<EditGradedOralScreen> createState() => _EditGradedOralScreenState();
}

class _EditGradedOralScreenState extends State<EditGradedOralScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final TextEditingController _dateController;
  late final TextEditingController _scoreController;
  late final TextEditingController _totalController;
  late final TextEditingController _remarksController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final date = _parseDate(widget.oralData?['date']);
    _dateController = TextEditingController(text: _formatDate(date));
    _scoreController = TextEditingController(
      text: '${widget.oralData?['score'] ?? 0}',
    );
    _totalController = TextEditingController(
      text: '${widget.oralData?['totalPoints'] ?? 100}',
    );
    _remarksController = TextEditingController(
      text: widget.oralData?['remarks']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _scoreController.dispose();
    _totalController.dispose();
    _remarksController.dispose();
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
        'gradedOral': {
          widget.selectedPeriod: {
            'date': Timestamp.fromDate(date),
            'score': score,
            'totalPoints': totalPoints,
            'remarks': _remarksController.text.trim(),
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
          content: Text('Error updating graded oral: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Graded Oral'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
            controller: _remarksController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Remarks'),
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
