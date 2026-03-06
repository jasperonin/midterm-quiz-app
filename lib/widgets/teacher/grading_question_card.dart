// lib/widgets/teacher/grading_question_card.dart
import 'package:flutter/material.dart';
import '../../models/student_submission.dart';

class GradingQuestionCard extends StatefulWidget {
  final CodingAnswer answer;
  final int questionNumber;
  final int totalQuestions;
  final int maxScore;
  final Function(int? score) onGrade; // Removed feedback parameter

  const GradingQuestionCard({
    Key? key,
    required this.answer,
    required this.questionNumber,
    required this.totalQuestions,
    required this.maxScore,
    required this.onGrade,
  }) : super(key: key);

  @override
  _GradingQuestionCardState createState() => _GradingQuestionCardState();
}

class _GradingQuestionCardState extends State<GradingQuestionCard> {
  late TextEditingController _scoreController;
  late int? _selectedScore;

  @override
  void didUpdateWidget(GradingQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller if the answer score changed
    if (oldWidget.answer.score != widget.answer.score) {
      _selectedScore = widget.answer.score;
      _scoreController.text = widget.answer.score?.toString() ?? '';
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedScore = widget.answer.score;
    _scoreController = TextEditingController(
      text: widget.answer.score?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  Color _getDifficultyColor() {
    switch (widget.answer.difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isGraded = widget.answer.score != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isGraded ? Colors.green : Colors.grey.shade300,
          width: isGraded ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _getDifficultyColor().withOpacity(0.1),
                  child: Text(
                    '${widget.questionNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getDifficultyColor(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${widget.questionNumber} of ${widget.totalQuestions}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        widget.answer.difficulty.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getDifficultyColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isGraded)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Graded: ${widget.answer.score}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Code display - FLEXIBLE to fix overflow
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade800, width: 2),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      widget.answer.code.isEmpty
                          ? '// No code submitted'
                          : widget.answer.code,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Score input - STRETCHED to full width
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _scoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Score (max: ${widget.maxScore})',
                      hintText: 'Enter 0-${widget.maxScore}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.stars, size: 18),
                      suffixText: '/ ${widget.maxScore}',
                    ),
                    onChanged: (value) {
                      int? parsedScore = int.tryParse(value);

                      if (parsedScore != null) {
                        if (parsedScore > widget.maxScore) {
                          _scoreController.text = widget.maxScore.toString();
                          _selectedScore = widget.maxScore;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Max score is ${widget.maxScore}'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        } else if (parsedScore < 0) {
                          _scoreController.text = '0';
                          _selectedScore = 0;
                        } else {
                          _selectedScore = parsedScore;
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onGrade(_selectedScore);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Question ${widget.questionNumber} graded',
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
