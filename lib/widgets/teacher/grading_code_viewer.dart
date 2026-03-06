// lib/screens/teacher/widgets/grading_code_viewer.dart
import 'package:flutter/material.dart';
import '../../../models/student_submission.dart';

class GradingCodeViewer extends StatefulWidget {
  final CodingAnswer answer;
  final int questionNumber;
  final Function(int? score, String feedback) onGrade;

  const GradingCodeViewer({
    Key? key,
    required this.answer,
    required this.questionNumber,
    required this.onGrade,
  }) : super(key: key);

  @override
  _GradingCodeViewerState createState() => _GradingCodeViewerState();
}

class _GradingCodeViewerState extends State<GradingCodeViewer> {
  late TextEditingController _scoreController;
  late TextEditingController _feedbackController;
  late int? _selectedScore;

  @override
  void initState() {
    super.initState();
    _selectedScore = widget.answer.score;
    _scoreController = TextEditingController(
      text: widget.answer.score?.toString() ?? '',
    );
    _feedbackController = TextEditingController(
      text: widget.answer.feedback ?? '',
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _feedbackController.dispose();
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with question number and difficulty
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _getDifficultyColor().withOpacity(0.1),
                  child: Text(
                    '${widget.questionNumber}',
                    style: TextStyle(
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
                        'Question ${widget.questionNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.answer.difficulty.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getDifficultyColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.answer.score != null
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.answer.score != null
                        ? 'Score: ${widget.answer.score}'
                        : 'Not graded',
                    style: TextStyle(
                      color: widget.answer.score != null
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Code display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade800, width: 8),
              ),
              child: SingleChildScrollView(
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

            const SizedBox(height: 16),

            // Scoring and feedback
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Score input
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _scoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Score',
                      hintText: 'Enter points',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.stars, size: 18),
                    ),
                    onChanged: (value) {
                      _selectedScore = int.tryParse(value);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Update button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  widget.onGrade(_selectedScore, _feedbackController.text);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Question ${widget.questionNumber} graded'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Grade'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
