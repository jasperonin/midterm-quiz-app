// lib/screens/teacher/student_submission_view.dart
import 'package:flutter/material.dart';
import '../../models/student_submission.dart';
import '../../widgets/teacher/grading_question_card.dart';
import '../../widgets/teacher/grading_footer.dart';

class StudentSubmissionView extends StatefulWidget {
  final StudentSubmission submission;
  final Function(StudentSubmission) onSave;

  const StudentSubmissionView({
    super.key,
    required this.submission,
    required this.onSave,
  });

  @override
  _StudentSubmissionViewState createState() => _StudentSubmissionViewState();
}

class _StudentSubmissionViewState extends State<StudentSubmissionView> {
  late List<CodingAnswer> _answers;
  late Map<int, int?> _scores;
  late Map<int, String> _feedback;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _answers = List.from(widget.submission.answers);
    _currentIndex = 0;
    _initializeScores();
  }

  void _initializeScores() {
    _scores = {};
    _feedback = {};
    for (int i = 0; i < _answers.length; i++) {
      _scores[i] = _answers[i].score;
      _feedback[i] = _answers[i].feedback ?? '';
    }
  }

  void _updateGrade(int index, int? score, [String feedback = '']) {
    setState(() {
      _scores[index] = score;
      _answers[index] = CodingAnswer(
        questionId: _answers[index].questionId,
        difficulty: _answers[index].difficulty,
        code: _answers[index].code,
        submittedAt: _answers[index].submittedAt,
        score: score,
        feedback: feedback,
      );
    });
  }

  int _calculateTotalScore() {
    int total = 0;
    _scores.forEach((_, score) {
      if (score != null) total += score;
    });
    return total;
  }

  bool _allGraded() {
    return _scores.values.every((score) => score != null);
  }

  // Update the _getMaxScoreForQuestion method to use difficulty, not just question ID

  int _getMaxScoreForQuestion(CodingAnswer answer) {
    // Use the difficulty from the answer to determine max score
    switch (answer.difficulty) {
      case 'easy':
        return 10;
      case 'medium':
        return 15;
      case 'hard':
        return 25;
      default:
        return 10;
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _goToNext() {
    if (_currentIndex < _answers.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_answers.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.submission.studentName),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No answers submitted'),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    int gradedCount = _scores.values.where((s) => s != null).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.submission.studentName),
            Text(
              'ID: ${widget.submission.studentId}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Progress
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Question ${_currentIndex + 1} of ${_answers.length}'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$gradedCount/${_answers.length} graded',
                        style: TextStyle(color: Colors.teal.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _answers.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _allGraded() ? Colors.green : Colors.teal,
                  ),
                ),
              ],
            ),
          ),

          // Question card
          // In student_submission_view.dart, replace the GradingQuestionCard section:
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GradingQuestionCard(
                answer: _answers[_currentIndex],
                questionNumber: _currentIndex + 1,
                totalQuestions: _answers.length,
                maxScore: _getMaxScoreForQuestion(
                  _answers[_currentIndex],
                ), // Fixed: uses difficulty
                onGrade: (score) => _updateGrade(_currentIndex, score),
              ),
            ),
          ),

          // Navigation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _currentIndex > 0 ? _goToPrevious : null,
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentIndex < _answers.length - 1
                        ? _goToNext
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: Text(
                      _currentIndex < _answers.length - 1 ? 'Next' : 'Last',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Footer
          GradingFooter(
            totalScore: _calculateTotalScore(),
            maxPossibleScore: 50,
            allGraded: _allGraded(),
            onSubmit: () {
              StudentSubmission updated = StudentSubmission(
                studentId: widget.submission.studentId,
                studentName: widget.submission.studentName,
                status: _allGraded() ? 'graded' : 'submitted',
                submittedAt: widget.submission.submittedAt,
                totalScore: _calculateTotalScore(),
                answers: _answers,
              );
              widget.onSave(updated);
              Navigator.pop(context, updated);
            },
          ),
        ],
      ),
    );
  }
}
