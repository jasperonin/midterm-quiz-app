import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditHandsOnScreen extends StatefulWidget {
  final String studentId;
  final String selectedPeriod;
  final List<Map<String, dynamic>> allActivities;

  const EditHandsOnScreen({
    super.key,
    required this.studentId,
    required this.selectedPeriod,
    required this.allActivities,
  });

  @override
  State<EditHandsOnScreen> createState() => _EditHandsOnScreenState();
}

class _EditHandsOnScreenState extends State<EditHandsOnScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<TextEditingController> _titleControllers = [];
  final List<TextEditingController> _dateControllers = [];
  final List<TextEditingController> _scoreControllers = [];
  final List<TextEditingController> _maxScoreControllers = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.allActivities.length; i++) {
      final item = widget.allActivities[i];
      if ((item['period'] ?? 'midterm') == widget.selectedPeriod) {
        _titleControllers.add(
          TextEditingController(text: item['title']?.toString() ?? ''),
        );
        _dateControllers.add(
          TextEditingController(text: _formatDate(_parseDate(item['date']))),
        );
        _scoreControllers.add(
          TextEditingController(text: '${item['score'] ?? 0}'),
        );
        _maxScoreControllers.add(
          TextEditingController(text: '${item['maxScore'] ?? 100}'),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _titleControllers) {
      c.dispose();
    }
    for (final c in _dateControllers) {
      c.dispose();
    }
    for (final c in _scoreControllers) {
      c.dispose();
    }
    for (final c in _maxScoreControllers) {
      c.dispose();
    }
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

  void _addActivity() {
    setState(() {
      _titleControllers.add(TextEditingController(text: ''));
      _dateControllers.add(
        TextEditingController(text: _formatDate(DateTime.now())),
      );
      _scoreControllers.add(TextEditingController(text: ''));
      _maxScoreControllers.add(TextEditingController(text: ''));
    });
  }

  Future<void> _save() async {
    final userDoc = await _firestore
        .collection('users')
        .doc(widget.studentId)
        .get();
    final existingActivities = userDoc.data()?['handsOnActivities'];

    final allExisting = existingActivities is List
        ? existingActivities
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList()
        : <Map<String, dynamic>>[];

    final updated = <Map<String, dynamic>>[];

    // Keep all activities not in this selected period
    for (final item in allExisting) {
      if ((item['period'] ?? 'midterm') != widget.selectedPeriod) {
        updated.add(item);
      }
    }

    for (var i = 0; i < _titleControllers.length; i++) {
      final title = _titleControllers[i].text.trim();
      final date = DateTime.tryParse(_dateControllers[i].text.trim());
      final score = int.tryParse(_scoreControllers[i].text.trim());
      final maxScore = int.tryParse(_maxScoreControllers[i].text.trim());

      if (title.isEmpty ||
          date == null ||
          score == null ||
          maxScore == null ||
          maxScore <= 0 ||
          score < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter valid hands-on values'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final payload = {
        'title': title,
        'date': Timestamp.fromDate(date),
        'score': score,
        'maxScore': maxScore,
        'period': widget.selectedPeriod,
      };

      // Append or replace (selected period batch update)
      updated.add(payload);
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestore.collection('users').doc(widget.studentId).update({
        'handsOnActivities': updated,
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
          content: Text('Error updating hands-on activities: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Hands-On'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _addActivity,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _titleControllers.isEmpty
          ? Center(
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _addActivity,
                icon: const Icon(Icons.add),
                label: const Text('Add Activity'),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _addActivity,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Activity'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _titleControllers.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextField(
                                controller: _titleControllers[index],
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _dateControllers[index],
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  hintText: 'YYYY-MM-DD',
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _scoreControllers[index],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Score',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _maxScoreControllers[index],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Total',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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
