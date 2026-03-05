// lib/screens/major_exam/major_exam_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/tab_switch_detector.dart';
import '../../services/connection_service.dart';
import 'coding_selection.dart';
import 'written_selection.dart';

class MajorExamScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const MajorExamScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  _MajorExamScreenState createState() => _MajorExamScreenState();
}

class _MajorExamScreenState extends State<MajorExamScreen> {
  int _currentSection = 0; // 0 = Written, 1 = Coding

  // Separate detectors for each section
  late TabSwitchDetector _writtenDetector;
  late ConnectionService _connection;

  // Written section state
  int _writtenScore = 0;
  bool _writtenCompleted = false;

  // Coding section state
  int _codingScore = 0;
  bool _codingCompleted = false;

  @override
  void initState() {
    super.initState();

    // Initialize connection service
    _connection = ConnectionService();
    _connection.initialize();

    // Initialize written section detector (WITH tab counting)
    _writtenDetector = TabSwitchDetector(
      studentId: widget.studentId,
      onViolation: (count) {
        if (mounted && _currentSection == 0) {
          setState(() {});
          if (count == 1) {
            _showViolationWarning();
          }
        }
      },
      onMaxViolationsReached: () {
        if (_currentSection == 0) {
          _terminateExam();
        }
      },
    );

    // Set initial flags in Firestore
    _setExamFlags();
  }

  Future<void> _setExamFlags() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .set({
            'isCurrentlyTakingWritten': true,
            'isCurrentlyTakingCoding': false,
            'examStatus': 'active',
            'lastActive': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      debugPrint('✅ Exam flags set: Written active');
    } catch (e) {
      debugPrint('❌ Error setting exam flags: $e');
    }
  }

  Future<void> _completeWrittenSection(int score) async {
    setState(() {
      _writtenScore = score;
      _writtenCompleted = true;
    });

    // Update flags
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .set({
            'isCurrentlyTakingWritten': false, // Written completed
            'isCurrentlyTakingCoding': true, // Ready for coding
            'writtenScore': score,
            'writtenCompletedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // Show completion dialog with option to continue or go home
      _showWrittenCompleteDialog();
    } catch (e) {
      print('❌ Error updating flags: $e');
    }
  }

  void _showWrittenCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Written Section Complete!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Your score: $_writtenScore'),
            const SizedBox(height: 8),
            const Text(
              'You can now proceed to the Coding section.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.popUntil(context, (route) => route.isFirst); // Go home
            },
            child: const Text('Return Home'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              setState(() {
                _currentSection = 1; // Move to coding section
              });
            },
            child: const Text('Continue to Coding'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeCodingSection(int score) async {
    setState(() {
      _codingScore = score;
      _codingCompleted = true;
    });

    // Calculate total score
    int totalScore = _writtenScore + _codingScore;

    // Finalize exam
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .set({
            'isCurrentlyTakingWritten': false,
            'isCurrentlyTakingCoding': false,
            'codingScore': score,
            'totalScore': totalScore,
            'hasTakenExam': true,
            'examStatus': 'inactive',
            'completedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      debugPrint('✅ Major exam completed. Total score: $totalScore');
    } catch (e) {
      debugPrint('❌ Error finalizing exam: $e');
    }

    _showCompletionDialog(totalScore);
  }

  void _showViolationWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Warning!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You switched away from the Written section.'),
            const SizedBox(height: 16),
            Text(
              'Violation ${_writtenDetector.violationCount} of 2',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coding section will NOT count violations.',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  void _terminateExam() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.gpp_bad, color: Colors.red, size: 48),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Exam Terminated',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'You switched tabs too many times during the Written section.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Return Home'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(int totalScore) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Major Exam Complete!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Written: $_writtenScore',
              style: const TextStyle(fontSize: 16),
            ),
            Text('Coding: $_codingScore', style: const TextStyle(fontSize: 16)),
            const Divider(),
            Text(
              'Total: $totalScore',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Return Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedSection(String title, int score) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Completed with score: $score',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Text(
              'You have already completed this section.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentSection == 0 ? 'Written Section' : 'Coding Section',
        ),
        backgroundColor: _currentSection == 0 ? Colors.purple : Colors.teal,
        actions: [
          if (_currentSection == 0)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _writtenDetector.violationCount > 0
                    ? Colors.orange.shade100
                    : Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    size: 16,
                    color: _writtenDetector.violationCount > 0
                        ? Colors.orange
                        : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_writtenDetector.violationCount}/2',
                    style: TextStyle(
                      color: _writtenDetector.violationCount > 0
                          ? Colors.orange.shade900
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentSection,
        children: [
          // Written Section (with tab counting)
          _writtenCompleted
              ? _buildCompletedSection('Written Section', _writtenScore)
              : WrittenSection(
                  studentId: widget.studentId,
                  studentName: widget.studentName,
                  detector: _writtenDetector,
                  onComplete: _completeWrittenSection,
                ),

          // Coding Section
          CodingSection(
            studentId: widget.studentId,
            studentName: widget.studentName,
            onComplete: _completeCodingSection,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _writtenDetector.stopMonitoring();
    super.dispose();
  }
}
