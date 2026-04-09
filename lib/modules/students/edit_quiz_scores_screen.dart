import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditQuizScoresScreen extends StatefulWidget {
  final String studentId;
  final String selectedPeriod;
  final List<Map<String, dynamic>> quizScores;

  const EditQuizScoresScreen({
    super.key,
    required this.studentId,
    required this.selectedPeriod,
    required this.quizScores,
  });

  @override
  State<EditQuizScoresScreen> createState() => _EditQuizScoresScreenState();
}

class _EditQuizScoresScreenState extends State<EditQuizScoresScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<int> _selectedIndexes = [];
  final List<Map<String, dynamic>> _selectedQuizzes = [];
  final List<TextEditingController> _dateControllers = [];
  final List<TextEditingController> _scoreControllers = [];
  final List<TextEditingController> _maxScoreControllers = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < widget.quizScores.length; i++) {
      final quiz = widget.quizScores[i];
      if ((quiz['period'] ?? 'midterm') == widget.selectedPeriod) {
        _selectedIndexes.add(i);
        _selectedQuizzes.add(Map<String, dynamic>.from(quiz));
      }
    }

    _scoreControllers.addAll(
      _selectedQuizzes
          .map((quiz) => TextEditingController(text: '${quiz['score'] ?? 0}')),
    );
    _dateControllers.addAll(
      _selectedQuizzes.map(
        (quiz) => TextEditingController(
          text: _formatDate(_parseDate(quiz['completedAt'])),
        ),
      ),
    );
    _maxScoreControllers.addAll(
      _selectedQuizzes.map(
        (quiz) => TextEditingController(text: '${quiz['totalPoints'] ?? 100}'),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _dateControllers) {
      controller.dispose();
    }
    for (final controller in _scoreControllers) {
      controller.dispose();
    }
    for (final controller in _maxScoreControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  DateTime _parseDate(dynamic dateValue) {
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      return DateTime.tryParse(dateValue) ?? DateTime.now();
    }
    return DateTime.now();
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  void _addManualEntry() {
    final now = DateTime.now();
    setState(() {
      _selectedIndexes.add(-1);
      _selectedQuizzes.add({
        'completedAt': now,
        'score': 0,
        'totalPoints': 100,
        'period': widget.selectedPeriod,
      });
      _dateControllers.add(TextEditingController(text: _formatDate(now)));
      _scoreControllers.add(TextEditingController(text: '0'));
      _maxScoreControllers.add(TextEditingController(text: '100'));
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _dateControllers[index].dispose();
      _scoreControllers[index].dispose();
      _maxScoreControllers[index].dispose();
      _dateControllers.removeAt(index);
      _scoreControllers.removeAt(index);
      _maxScoreControllers.removeAt(index);
      _selectedIndexes.removeAt(index);
      _selectedQuizzes.removeAt(index);
    });
  }

  Future<void> _save() async {
    final keptExistingIndexes = _selectedIndexes
        .where((index) => index >= 0)
        .toSet();
    final updatedQuizScores = <Map<String, dynamic>>[];
    final existingIndexToUpdatedIndex = <int, int>{};

    for (var i = 0; i < widget.quizScores.length; i++) {
      final quiz = widget.quizScores[i];
      final period = quiz['period'] ?? 'midterm';
      if (period == widget.selectedPeriod && !keptExistingIndexes.contains(i)) {
        continue;
      }
      existingIndexToUpdatedIndex[i] = updatedQuizScores.length;
      updatedQuizScores.add(Map<String, dynamic>.from(quiz));
    }

    for (var i = 0; i < _selectedIndexes.length; i++) {
      final score = int.tryParse(_scoreControllers[i].text.trim());
      final totalPoints = int.tryParse(_maxScoreControllers[i].text.trim());

      if (score == null || totalPoints == null || totalPoints <= 0 || score < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter valid numeric quiz scores'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final percentage = double.parse(
        ((score / totalPoints) * 100).toStringAsFixed(1),
      );
      final selectedIndex = _selectedIndexes[i];
      final completedAt = DateTime.tryParse(_dateControllers[i].text.trim());

      if (completedAt == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter a valid date using YYYY-MM-DD'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (selectedIndex >= 0) {
        final updatedIndex = existingIndexToUpdatedIndex[selectedIndex];
        if (updatedIndex == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to update quiz score. Please reopen and try again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        updatedQuizScores[updatedIndex]['score'] = score;
        updatedQuizScores[updatedIndex]['totalPoints'] = totalPoints;
        updatedQuizScores[updatedIndex]['percentage'] = percentage;
        updatedQuizScores[updatedIndex]['completedAt'] =
            Timestamp.fromDate(completedAt);
      } else {
        updatedQuizScores.add({
          'completedAt': Timestamp.fromDate(completedAt),
          'percentage': percentage,
          'period': widget.selectedPeriod,
          'quizId': 'default_quiz',
          'score': score,
          'timeSpent': completedAt.millisecondsSinceEpoch ~/ 1000,
          'totalPoints': totalPoints,
        });
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestore.collection('users').doc(widget.studentId).update({
        'scores.quizScores': updatedQuizScores,
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
          content: Text('Error updating quiz scores: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Quiz Scores'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _addManualEntry,
            icon: const Icon(Icons.add),
            tooltip: 'Add Manual Score',
          ),
        ],
      ),
      body: _selectedQuizzes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No quiz scores found for this period'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _addManualEntry,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Manual Score'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _selectedQuizzes.length,
              itemBuilder: (context, index) {
                final isManualEntry = _selectedIndexes[index] == -1;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quiz ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 132,
                                child: TextField(
                                  controller: _dateControllers[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Date',
                                    hintText: 'YYYY-MM-DD',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              if (isManualEntry) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Manual',
                                    style: TextStyle(
                                      color: Colors.teal.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 84,
                          child: TextField(
                            controller: _scoreControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Score',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 84,
                          child: TextField(
                            controller: _maxScoreControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Total',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: _isSaving ? null : () => _removeEntry(index),
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete quiz score',
                          color: Colors.red.shade400,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: _selectedQuizzes.isEmpty
          ? null
          : SafeArea(
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
