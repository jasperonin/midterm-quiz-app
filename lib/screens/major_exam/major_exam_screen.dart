// lib/screens/major_exam/major_exam_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/tab_switch_detector.dart';
import '../../services/connection_service.dart';
import '../../services/major_exam_service.dart';
import 'coding_selection.dart';
import 'written_selection.dart';

class MajorExamScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const MajorExamScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  _MajorExamScreenState createState() => _MajorExamScreenState();
}

class _MajorExamScreenState extends State<MajorExamScreen> {
  late MajorExamService _examService;
  late TabSwitchDetector _writtenDetector;
  late ConnectionService _connection;
  
  // UI State
  bool _isLoading = true;
  ExamResumeStatus? _resumeStatus;
  String? _errorMessage;
  
  // Exam state
  int _currentSection = 0; // 0 = Written, 1 = Coding
  int _writtenScore = 0;
  bool _writtenCompleted = false;
  bool _codingCompleted = false;

  @override
  void initState() {
    super.initState();
    _examService = MajorExamService(studentId: widget.studentId);
    _connection = ConnectionService();
    _connection.initialize();
    
    _initializeExam();
  }
  
  Future<void> _initializeExam() async {
    setState(() => _isLoading = true);
    
    try {
      // Check where the student should be
      _resumeStatus = await _examService.checkExamStatus();
      
      print('📋 Exam resume status: $_resumeStatus');
      
      switch (_resumeStatus) {
        case ExamResumeStatus.completed:
          // Show already completed message
          setState(() {
            _isLoading = false;
            _errorMessage = 'You have already completed this exam.';
          });
          break;
          
        case ExamResumeStatus.resumeCoding:
          // Skip to coding section
          setState(() {
            _currentSection = 1;
            _writtenCompleted = true; // Mark written as completed
            _isLoading = false;
          });
          
          // Initialize coding section (no tab detector needed)
          await _examService.startCodingSection();
          break;
          
        case ExamResumeStatus.startWritten:
        case ExamResumeStatus.newExam:
          // Start fresh with written section
          _initializeWrittenSection();
          break;
        case null:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing exam: $e';
        _isLoading = false;
      });
    }
  }
  
  void _initializeWrittenSection() {
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
    
    // Set written flag
    _examService.startCodingSection(); // Actually this should be for written
    // We need a separate method for written start
    
    setState(() => _isLoading = false);
  }
  
  Future<void> _completeWrittenSection(int score) async {
    setState(() {
      _writtenScore = score;
      _writtenCompleted = true;
    });
    
    // Mark written as completed
    await _examService.markWrittenCompleted(score: score);
    
    // Stop written detector (no more counting)
    _writtenDetector.stopMonitoring();
    
    // Show completion dialog with options
    _showWrittenCompleteDialog();
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
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Start coding section
              await _examService.startCodingSection();
              
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
      _codingCompleted = true;
    });
    
    // Finalize exam
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .set({
        'isCurrentlyTakingWritten': true,
        'isCurrentlyTakingCoding': true,
        'codingScore': score,
        'hasTakenExam': true,
        'examStatus': 'inactive',
        'completedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      _showCompletionDialog();
    } catch (e) {
      print('❌ Error finalizing exam: $e');
    }
  }
  
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Major Exam Complete!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Thank you for completing the exam.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Return Home'),
          ),
        ],
      ),
    );
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
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completed with score: $score',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
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
    // Loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Major Exam'),
          backgroundColor: Colors.purple,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Error/completed state
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Major Exam'),
          backgroundColor: Colors.purple,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _resumeStatus == ExamResumeStatus.completed 
                      ? Icons.check_circle 
                      : Icons.error_outline,
                  size: 64,
                  color: _resumeStatus == ExamResumeStatus.completed 
                      ? Colors.green 
                      : Colors.red,
                ),
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Return Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentSection == 0 ? 'Written Section' : 'Coding Section',
        ),
        backgroundColor: _currentSection == 0 ? Colors.purple : Colors.teal,
        actions: [
          if (_currentSection == 0 && _writtenDetector != null)
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
          // Written Section
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