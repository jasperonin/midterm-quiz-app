// lib/widgets/exam_selection/exam_selection_modal.dart
import 'package:flutter/material.dart';
import '../../models/exam_type.dart';
import 'exam_type_card.dart';

class ExamSelectionModal extends StatefulWidget {
  final String studentId;
  final String studentName;

  const ExamSelectionModal({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  _ExamSelectionModalState createState() => _ExamSelectionModalState();
}

class _ExamSelectionModalState extends State<ExamSelectionModal> {
  ExamType? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school,
                    color: Colors.blue.shade800,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${widget.studentName}!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${widget.studentId}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Instruction
            const Text(
              'Please select exam type:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 16),

            // Exam type options
            ExamTypeCard(
              type: ExamType.regularQuiz,
              isSelected: _selectedType == ExamType.regularQuiz,
              onTap: () {
                setState(() {
                  _selectedType = ExamType.regularQuiz;
                });
              },
            ),

            ExamTypeCard(
              type: ExamType.majorExam,
              isSelected: _selectedType == ExamType.majorExam,
              onTap: () {
                setState(() {
                  _selectedType = ExamType.majorExam;
                });
              },
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedType == null
                        ? null
                        : () {
                            Navigator.pop(context, _selectedType);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedType?.color ?? Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Note about major exam
            if (_selectedType == ExamType.majorExam)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.purple.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Major exam has 2 parts: Written and Coding. '
                        'Tab switching is only monitored during Written section.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
