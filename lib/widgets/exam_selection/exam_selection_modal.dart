// lib/widgets/exam_selection/exam_selection_modal.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? _selectedReportType;
  double? _midtermGrade;
  double? _finalsGrade;

  // Course-specific grades
  double? _midtermGradeLecture;
  double? _midtermGradeLab;
  double? _finalsGradeLecture;
  double? _finalsGradeLab;

  bool _isReportExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .get();

      if (doc.exists && doc.data() != null) {
        final grades = doc.data()!['grades'];
        if (grades != null && grades is Map<String, dynamic>) {
          setState(() {
            // Load course-specific grades
            _midtermGradeLecture = grades['midterm_grade_lecture'] != null
                ? (grades['midterm_grade_lecture'] as num).toDouble()
                : null;
            _midtermGradeLab = grades['midterm_grade_lab'] != null
                ? (grades['midterm_grade_lab'] as num).toDouble()
                : null;
            _finalsGradeLecture = grades['finals_grade_lecture'] != null
                ? (grades['finals_grade_lecture'] as num).toDouble()
                : null;
            _finalsGradeLab = grades['finals_grade_lab'] != null
                ? (grades['finals_grade_lab'] as num).toDouble()
                : null;

            // Set default display to lecture
            _midtermGrade = _midtermGradeLecture;
            _finalsGrade = _finalsGradeLecture;
          });
        }
      }
    } catch (e) {
      // Handle error silently for now
      debugPrint('Error loading grades: $e');
    }
  }

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

            // Generate report card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isReportExpanded = !_isReportExpanded;
                        });
                      },
                      child: Row(
                        children: [
                          const Text(
                            'Generate Report',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _isReportExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                    if (_isReportExpanded) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Lecture'),
                            selected: _selectedReportType == 'Lecture',
                            onSelected: (_) {
                              setState(() {
                                _selectedReportType = 'Lecture';
                                _midtermGrade = _midtermGradeLecture;
                                _finalsGrade = _finalsGradeLecture;
                              });
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Lab'),
                            selected: _selectedReportType == 'Lab',
                            onSelected: (_) {
                              setState(() {
                                _selectedReportType = 'Lab';
                                _midtermGrade = _midtermGradeLab;
                                _finalsGrade = _finalsGradeLab;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_selectedReportType != null) ...[
                        const SizedBox(height: 16),
                        // Display selected course grades
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Midterm: ${_midtermGrade?.toStringAsFixed(2) ?? '-'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Finals: ${_finalsGrade?.toStringAsFixed(2) ?? '-'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$_selectedReportType Breakdown',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_selectedReportType == 'Lecture') ...[
                          _buildBreakdownRow('Quiz', '30%'),
                          _buildBreakdownRow('Oral', '20%'),
                          _buildBreakdownRow('Project', '10%'),
                          _buildBreakdownRow('Exam', '40%'),
                        ] else ...[
                          _buildBreakdownRow('Quiz', '20%'),
                          _buildBreakdownRow('Oral', '10%'),
                          _buildBreakdownRow('Hands-on', '30%'),
                          _buildBreakdownRow('Project', '20%'),
                          _buildBreakdownRow('Exam', '20%'),
                        ],
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'Term Grade',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Midterm (Lecture)${_midtermGradeLecture != null ? ' (${_midtermGradeLecture!.toStringAsFixed(2)})' : ''}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Midterm (Lab)${_midtermGradeLab != null ? ' (${_midtermGradeLab!.toStringAsFixed(2)})' : ''}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Finals (Lecture)${_finalsGradeLecture != null ? ' (${_finalsGradeLecture!.toStringAsFixed(2)})' : ''}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Finals (Lab)${_finalsGradeLab != null ? ' (${_finalsGradeLab!.toStringAsFixed(2)})' : ''}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
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

  Widget _buildBreakdownRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
