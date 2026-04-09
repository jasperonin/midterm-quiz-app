// lib/modules/students/student_details_screen.dart
import 'package:app/models/student_submission.dart';
import 'package:app/modules/students/edit_graded_oral_screen.dart';
import 'package:app/modules/students/edit_hands_on_screen.dart';
import 'package:app/modules/students/edit_project_screen.dart';
import 'package:app/modules/students/edit_written_score_screen.dart';
import 'package:app/screens/teacher/student_submission.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/modules/students/edit_quiz_scores_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/student/period_selector.dart';
import '../../widgets/student/quiz_section.dart';
import '../../widgets/student/graded_oral_section.dart';
import '../../widgets/student/hands_on_section.dart';
import '../../widgets/student/project_section.dart';
import '../../widgets/student/exam_section.dart';
import '../../widgets/student/final_computation_card.dart';
import '../../widgets/student/course_selector.dart';

class StudentDetailsScreen extends StatefulWidget {
  final String studentId;
  final String teacherId;
  final String? studentName;

  const StudentDetailsScreen({
    super.key,
    required this.studentId,
    required this.teacherId,
    this.studentName,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;
  String? _errorMessage;

  // Period selection
  String _selectedPeriod = 'midterm';

  // Course selection
  String _selectedCourse = 'lecture';

  // Weights based on course
  late double _quizWeight;
  late double _oralWeight;
  late double _handsOnWeight;
  late double _projectWeight;
  late double _examWeight;

  // Section data
  List<Map<String, dynamic>> _quizzes = [];
  double _quizAverage = 0;
  double _quizWeighted = 0;

  int? _oralScore;
  int _oralMaxScore = 100;
  DateTime? _oralDate;
  String? _oralRemarks;

  List<Map<String, dynamic>> _handsOn = [];
  double _handsOnAverage = 0;
  double _handsOnWeighted = 0;

  int? _projectScore;
  int _projectMaxScore = 100;
  DateTime? _projectDate;
  String? _projectTitle;
  String? _projectFeedback;

  int? _codingScore;
  DateTime? _codingDate;
  int? _writtenScore;
  DateTime? _writtenDate;
  double _examAverage = 0;
  double _examWeighted = 0;

  double _totalPercentage = 0;
  double _finalGrade = 0;
  String _status = 'pending';

  double? _midtermGrade;
  double? _finalsGrade;

  // Course-specific grades (lecture vs lab)
  double? _midtermGradeLecture;
  double? _midtermGradeLab;
  double? _finalsGradeLecture;
  double? _finalsGradeLab;

  @override
  void initState() {
    super.initState();
    debugPrint('📂 StudentDetailsScreen opened for ID: ${widget.studentId}');
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _restoreSelectedCourse();
    _updateWeights();
    await _loadStudentData();
  }

  String get _selectedCoursePreferenceKey =>
      'student_details_selected_course_${widget.studentId}';

  Future<void> _restoreSelectedCourse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCourse = prefs.getString(_selectedCoursePreferenceKey);
      if (savedCourse == 'lecture' || savedCourse == 'lab') {
        _selectedCourse = savedCourse!;
      }
    } catch (e) {
      debugPrint('Could not restore selected course: $e');
    }
  }

  Future<void> _persistSelectedCourse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedCoursePreferenceKey, _selectedCourse);
    } catch (e) {
      debugPrint('Could not persist selected course: $e');
    }
  }

  void _updateWeights() {
    if (_selectedCourse == 'lecture') {
      _quizWeight = 0.30;
      _oralWeight = 0.20;
      _handsOnWeight = 0.0; // Not used
      _projectWeight = 0.10;
      _examWeight = 0.40;
    } else {
      // lab
      _quizWeight = 0.20;
      _oralWeight = 0.10;
      _handsOnWeight = 0.30;
      _projectWeight = 0.20;
      _examWeight = 0.20;
    }
  }

  Future<void> _loadStudentData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final doc = await _firestore
          .collection('users')
          .doc(widget.studentId)
          .get(const GetOptions(source: Source.serverAndCache));

      if (!mounted) return;

      if (doc.exists) {
        setState(() {
          _studentData = doc.data();
          _isLoading = false;
        });
        await _loadDataForPeriod();
      } else {
        setState(() {
          _errorMessage = 'Student not found';
          _isLoading = false;
        });
      }
    } on FirebaseException catch (e) {
      try {
        final cachedDoc = await _firestore
            .collection('users')
            .doc(widget.studentId)
            .get(const GetOptions(source: Source.cache));

        if (!mounted) return;

        if (cachedDoc.exists) {
          setState(() {
            _studentData = cachedDoc.data();
            _errorMessage = 'Using cached student data';
            _isLoading = false;
          });
          await _loadDataForPeriod(
            shouldSaveGrade: false,
            reloadExamData: false,
          );
        } else {
          setState(() {
            _errorMessage = 'Firebase error: ${e.message}';
            _isLoading = false;
          });
        }
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Firebase error: ${e.message}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDataForPeriod({
    bool shouldSaveGrade = true,
    bool reloadExamData = true,
  }) async {
    if (_studentData == null) return;

    try {
      // Safe access with null checks
      final scores = _studentData!['scores'];
      final grades = _studentData!['grades'];

      // ========== GRADES LOADING WITH MIGRATION SUPPORT ==========
      if (grades != null && grades is Map<String, dynamic>) {
        // Try to load course-specific grades first (new explicit format)
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

        // Migration: If old format exists but new format doesn't
        if (grades['midterm'] != null && _midtermGradeLecture == null) {
          debugPrint('🔄 Migrating old midterm grade to lecture format');
          _midtermGradeLecture = (grades['midterm'] as num).toDouble();
        }
        if (grades['finals'] != null && _finalsGradeLecture == null) {
          debugPrint('🔄 Migrating old finals grade to lecture format');
          _finalsGradeLecture = (grades['finals'] as num).toDouble();
        }
      }

      // Set display grades based on current course selection
      _midtermGrade = _selectedCourse == 'lecture'
          ? _midtermGradeLecture
          : _midtermGradeLab;
      _finalsGrade = _selectedCourse == 'lecture'
          ? _finalsGradeLecture
          : _finalsGradeLab;

      // ========== QUIZZES ==========
      final allQuizzes = (scores != null && scores['quizScores'] != null)
          ? List.from(scores['quizScores'])
          : [];

      _quizzes = [];
      int quizIndex = 1;
      for (var q in allQuizzes) {
        final period = q['period'] ?? 'midterm';
        if (period == _selectedPeriod) {
          _quizzes.add({
            'number': quizIndex++,
            'date': _parseDate(q['completedAt']),
            'score': q['score'] ?? 0,
            'maxScore': q['totalPoints'] ?? 100,
          });
        }
      }

      // Calculate quiz stats
      if (_quizzes.isNotEmpty) {
        double totalPercent = 0;
        for (var q in _quizzes) {
          totalPercent += (q['score'] / q['maxScore']) * 100;
        }
        _quizAverage = totalPercent / _quizzes.length;
        _quizWeighted = _quizAverage * _quizWeight;
      } else {
        _quizAverage = 0;
        _quizWeighted = 0;
      }

      // ========== GRADED ORAL ==========
      final gradedOral = _studentData!['gradedOral'];
      if (gradedOral != null && gradedOral[_selectedPeriod] != null) {
        final oralData = gradedOral[_selectedPeriod];
        _oralScore = oralData['score'];
        _oralMaxScore = oralData['totalPoints'] ?? 100;
        _oralDate = oralData['date'] != null
            ? _parseDate(oralData['date'])
            : null;
        _oralRemarks = oralData['remarks'];
      } else {
        _oralScore = null;
        _oralMaxScore = 100;
        _oralDate = null;
        _oralRemarks = null;
      }

      // ========== HANDS-ON ACTIVITIES ==========
      final allHandsOn = _studentData!['handsOnActivities'];
      _handsOn = [];
      if (allHandsOn != null && allHandsOn is List) {
        for (var a in allHandsOn) {
          final period = a['period'] ?? 'midterm';
          if (period == _selectedPeriod) {
            _handsOn.add({
              'title': a['title'] ?? 'Activity',
              'date': _parseDate(a['date']),
              'score': a['score'] ?? 0,
              'maxScore': a['maxScore'] ?? 100,
            });
          }
        }
      }

      // Calculate hands-on stats
      if (_handsOn.isNotEmpty) {
        double totalPercent = 0;
        for (var a in _handsOn) {
          totalPercent += (a['score'] / a['maxScore']) * 100;
        }
        _handsOnAverage = totalPercent / _handsOn.length;
        _handsOnWeighted = _handsOnAverage * _handsOnWeight;
      } else {
        _handsOnAverage = 0;
        _handsOnWeighted = 0;
      }

      // ========== PROJECT ==========
      final project = _studentData!['project'];
      if (project != null && project[_selectedPeriod] != null) {
        final projectData = project[_selectedPeriod];
        _projectScore = projectData['score'];
        _projectMaxScore = projectData['totalPoints'] ?? 100;
        _projectDate = projectData['date'] != null
            ? _parseDate(projectData['date'])
            : null;
        _projectTitle = projectData['title'];
        _projectFeedback = projectData['feedback'];
      } else {
        _projectScore = null;
        _projectMaxScore = 100;
        _projectDate = null;
        _projectTitle = null;
        _projectFeedback = null;
      }

      if (reloadExamData) {
        // ========== CODING EXAM (from separate collection) ==========
      try {
        final codingDoc = await _firestore
            .collection('codingExamAnswerByStudent')
            .doc(widget.studentId)
            .get();

        if (codingDoc.exists) {
          final codingData = codingDoc.data();
          final answers = codingData?['answers'] ?? [];
          final totalScore = codingData?['totalScore'] ?? 0;

          print('📊 Coding exam data found for ${widget.studentId}');
          print('   Total Score: $totalScore');
          print('   Answers: ${answers.length}');

          // Reset coding score
          _codingScore = null;
          _codingDate = null;

          // Sum up all scores from answers (since each answer has its own score)
          int sumScores = 0;
          for (var answer in answers) {
            final score = answer['score'] ?? 0;
            sumScores += score as int;
            print('   Question ${answer['questionId']}: $score points');
          }

          // Use the total score from the document or sum of answers
          if (totalScore > 0) {
            _codingScore = totalScore;
            print('✅ Using totalScore: $_codingScore');
          } else if (sumScores > 0) {
            _codingScore = sumScores;
            print('✅ Using sum of answers: $_codingScore');
          }

          // Get submission date from the document
          if (codingData?['submittedAt'] != null) {
            _codingDate = _parseDate(codingData!['submittedAt']);
          }
        } else {
          print('📊 No coding exam document found for ${widget.studentId}');
        }
      } catch (e) {
        print('❌ Error loading coding exam: $e');
      }

      // ========== WRITTEN EXAM (from users collection writtenScore) ==========
      try {
        // First try to get writtenScore from users collection
        final userWrittenScore = _studentData!['writtenScore'];
        if (userWrittenScore != null && userWrittenScore is int) {
          _writtenScore = userWrittenScore;
          print('📝 Written score from users collection: $_writtenScore');
        } else {
          // Fallback to writtenExamAnswerByStudent collection
          final writtenDoc = await _firestore
              .collection('writtenExamAnswerByStudent')
              .doc(widget.studentId)
              .get();

          if (writtenDoc.exists) {
            final writtenData = writtenDoc.data();
            final answers = writtenData?['answers'] ?? [];
            final totalScore = writtenData?['totalScore'] ?? 0;

            print('📝 Written exam data found for ${widget.studentId}');
            print('   Total Score: $totalScore');

            // Reset written score
            _writtenScore = null;
            _writtenDate = null;

            // Sum up all scores from answers
            int sumScores = 0;
            for (var answer in answers) {
              final score = answer['score'] ?? 0;
              sumScores += score as int;
            }

            if (totalScore > 0) {
              _writtenScore = totalScore;
            } else if (sumScores > 0) {
              _writtenScore = sumScores;
            }

            if (writtenData?['submittedAt'] != null) {
              _writtenDate = _parseDate(writtenData!['submittedAt']);
            }
          } else {
            print('📝 No written exam document found for ${widget.studentId}');
          }
        }
      } catch (e) {
        print('❌ Error loading written exam: $e');
      }

      }

      // Calculate exam average
      if (_selectedCourse == 'lecture') {
        _examAverage = _writtenScore != null ? (_writtenScore! / 40) * 100 : 0;
      } else {
        _examAverage = _codingScore != null ? (_codingScore! / 40) * 100 : 0;
      }
      _examWeighted = _examAverage * _examWeight;

      print('🏆 Exam Average: ${_examAverage.toStringAsFixed(1)}%');
      print('🏆 Exam Weighted: ${_examWeighted.toStringAsFixed(1)} pts');

      // ========== FINAL CALCULATION ==========
      _calculateFinalTotals();

      // Perform automatic data migration (old format → new format)
      await _performGradeMigration();

      // Only save grade if it's a recalculation scenario (not just a course switch)
      if (shouldSaveGrade) {
        await _saveTermGrade();
      }

      setState(() {});
    } catch (e) {
      print('❌ Error loading data for period: $e');
    }
  }

  Future<void> _saveTermGrade() async {
    try {
      // Save to course-specific key with explicit naming
      final gradeKey =
          '${_selectedPeriod}_grade_${_selectedCourse}'; // e.g., 'midterm_grade_lecture'

      await _firestore.collection('users').doc(widget.studentId).set({
        'grades': {gradeKey: _finalGrade},
      }, SetOptions(merge: true));

      debugPrint(
        '💾 Saved grade: $gradeKey = ${_finalGrade.toStringAsFixed(2)}',
      );
    } catch (e) {
      print('❌ Error saving term grade: $e');
    }
  }

  Future<void> _performGradeMigration() async {
    if (_studentData == null) return;

    try {
      final grades = _studentData!['grades'];
      if (grades == null || grades is! Map<String, dynamic>) return;

      final migrationUpdates = <String, dynamic>{};
      bool needsMigration = false;

      // Check if old midterm exists and new lecture format doesn't
      if (grades['midterm'] != null &&
          grades['midterm_grade_lecture'] == null) {
        debugPrint('📝 Migrating old midterm to midterm_grade_lecture');
        migrationUpdates['grades.midterm_grade_lecture'] =
            (grades['midterm'] as num).toDouble();
        needsMigration = true;
      }

      // Check if old finals exists and new lecture format doesn't
      if (grades['finals'] != null && grades['finals_grade_lecture'] == null) {
        debugPrint('📝 Migrating old finals to finals_grade_lecture');
        migrationUpdates['grades.finals_grade_lecture'] =
            (grades['finals'] as num).toDouble();
        needsMigration = true;
      }

      // If migration needed, save to Firestore
      if (needsMigration) {
        await _firestore
            .collection('users')
            .doc(widget.studentId)
            .update(migrationUpdates);
        debugPrint('✅ Grade migration complete');
      }
    } catch (e) {
      debugPrint('⚠️ Migration error (non-critical): $e');
    }
  }

  void _calculateFinalTotals() {
    _totalPercentage = _quizWeighted;

    // Add oral if exists
    if (_oralScore != null && _oralMaxScore > 0) {
      double oralPercent = _oralScore! / _oralMaxScore * 100;
      _totalPercentage += (oralPercent * _oralWeight);
    }

    // Add hands-on if for lab
    if (_selectedCourse == 'lab') {
      _totalPercentage += _handsOnWeighted;
    }

    // Add project if exists
    if (_projectScore != null && _projectMaxScore > 0) {
      double projectPercent = _projectScore! / _projectMaxScore * 100;
      _totalPercentage += (projectPercent * _projectWeight);
    }

    // Add exam
    _totalPercentage += _examWeighted;

    // Convert to 1.0-5.0 grade scale based on provided table
    if (_totalPercentage >= 99)
      _finalGrade = 1.0;
    else if (_totalPercentage >= 97)
      _finalGrade = 1.1;
    else if (_totalPercentage >= 95)
      _finalGrade = 1.2;
    else if (_totalPercentage >= 93)
      _finalGrade = 1.3;
    else if (_totalPercentage >= 91)
      _finalGrade = 1.4;
    else if (_totalPercentage >= 89)
      _finalGrade = 1.5;
    else if (_totalPercentage >= 87)
      _finalGrade = 1.6;
    else if (_totalPercentage >= 85)
      _finalGrade = 1.7;
    else if (_totalPercentage >= 81)
      _finalGrade = 1.9;
    else if (_totalPercentage >= 80)
      _finalGrade = 2.0;
    else if (_totalPercentage >= 79)
      _finalGrade = 2.1;
    else if (_totalPercentage >= 78)
      _finalGrade = 2.2;
    else if (_totalPercentage >= 77)
      _finalGrade = 2.3;
    else if (_totalPercentage >= 76)
      _finalGrade = 2.4;
    else if (_totalPercentage >= 75)
      _finalGrade = 2.5;
    else if (_totalPercentage >= 70)
      _finalGrade = 2.6;
    else if (_totalPercentage >= 65)
      _finalGrade = 2.7;
    else if (_totalPercentage >= 60)
      _finalGrade = 2.8;
    else if (_totalPercentage >= 55)
      _finalGrade = 2.9;
    else if (_totalPercentage >= 50)
      _finalGrade = 3.0;
    else if (_totalPercentage >= 45)
      _finalGrade = 3.2;
    else if (_totalPercentage >= 40)
      _finalGrade = 3.4;
    else if (_totalPercentage >= 35)
      _finalGrade = 3.6;
    else if (_totalPercentage >= 30)
      _finalGrade = 3.8;
    else if (_totalPercentage >= 25)
      _finalGrade = 4.0;
    else if (_totalPercentage >= 20)
      _finalGrade = 4.2;
    else if (_totalPercentage >= 15)
      _finalGrade = 4.4;
    else if (_totalPercentage >= 10)
      _finalGrade = 4.6;
    else if (_totalPercentage >= 5)
      _finalGrade = 4.8;
    else
      _finalGrade = 5.0;

    _status = _finalGrade <= 3.0 ? 'PASSED' : 'FAILED';

    // Update course-specific grades
    if (_selectedPeriod == 'midterm') {
      if (_selectedCourse == 'lecture') {
        _midtermGradeLecture = _finalGrade;
      } else {
        _midtermGradeLab = _finalGrade;
      }
      _midtermGrade = _finalGrade;
    } else {
      if (_selectedCourse == 'lecture') {
        _finalsGradeLecture = _finalGrade;
      } else {
        _finalsGradeLab = _finalGrade;
      }
      _finalsGrade = _finalGrade;
    }
  }

  DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Future<void> _openQuizEditScreen() async {
    final scores = _studentData?['scores'];
    final allQuizScores = scores != null && scores['quizScores'] is List
        ? List<Map<String, dynamic>>.from(
            (scores['quizScores'] as List).map(
              (quiz) => Map<String, dynamic>.from(quiz as Map),
            ),
          )
        : <Map<String, dynamic>>[];

    final selectedIndexes = <int>[];
    final selectedQuizzes = <Map<String, dynamic>>[];

    for (var i = 0; i < allQuizScores.length; i++) {
      final quiz = allQuizScores[i];
      if ((quiz['period'] ?? 'midterm') == _selectedPeriod) {
        selectedIndexes.add(i);
        selectedQuizzes.add(quiz);
      }
    }

    if (selectedQuizzes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No quiz scores found for this period'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final didSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditQuizScoresScreen(
          studentId: widget.studentId,
          selectedPeriod: _selectedPeriod,
          quizScores: allQuizScores,
        ),
      ),
    );

    if (didSave == true) {
      await _loadStudentData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz scores updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _openGradedOralEditScreen() async {
    final oralData = _studentData?['gradedOral']?[_selectedPeriod];
    final didSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditGradedOralScreen(
          studentId: widget.studentId,
          selectedPeriod: _selectedPeriod,
          oralData: oralData == null
              ? null
              : Map<String, dynamic>.from(oralData),
        ),
      ),
    );

    if (didSave == true) {
      await _loadStudentData();
    }
  }

  Future<void> _openHandsOnEditScreen() async {
    final activities = _studentData?['handsOnActivities'];
    final allActivities = activities is List
        ? activities
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList()
        : <Map<String, dynamic>>[];

    final didSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditHandsOnScreen(
          studentId: widget.studentId,
          selectedPeriod: _selectedPeriod,
          allActivities: allActivities,
        ),
      ),
    );

    if (didSave == true) {
      await _loadStudentData();
    }
  }

  Future<void> _openProjectEditScreen() async {
    final projectData = _studentData?['project']?[_selectedPeriod];
    final didSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProjectScreen(
          studentId: widget.studentId,
          selectedPeriod: _selectedPeriod,
          projectData: projectData == null
              ? null
              : Map<String, dynamic>.from(projectData),
        ),
      ),
    );

    if (didSave == true) {
      await _loadStudentData();
    }
  }

  Future<void> _openEditWrittenScreen() async {
    final didSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditWrittenScoreScreen(
          studentId: widget.studentId,
          selectedPeriod: _selectedPeriod,
          currentScore: _writtenScore,
          maxScore: 40,
        ),
      ),
    );

    if (didSave == true) {
      await _loadStudentData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Written score updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Student Details'),
          backgroundColor: Colors.teal,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Student Details'),
          backgroundColor: Colors.teal,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadStudentData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_studentData == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Student Details'),
          backgroundColor: Colors.teal,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text('Student not found'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildContent();
  }

  Widget _buildContent() {
    final name = _studentData!['name'] ?? 'Unnamed Student';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Student Details'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student ID card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person, color: Colors.teal.shade700),
                ),
                title: Text(
                  widget.studentName ?? name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Student ID: ${widget.studentId}'),
              ),
            ),
            const SizedBox(height: 12),

            // Midterm/Finals grade summary
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Midterm Grade (Lecture): ${_midtermGradeLecture?.toStringAsFixed(2) ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Midterm Grade (Lab): ${_midtermGradeLab?.toStringAsFixed(2) ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Finals Grade (Lecture): ${_finalsGradeLecture?.toStringAsFixed(2) ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Finals Grade (Lab): ${_finalsGradeLab?.toStringAsFixed(2) ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _finalGrade <= 3.0
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Current (${_selectedCourse.toUpperCase()}): ${_finalGrade.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _finalGrade <= 3.0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Period selector
            PeriodSelector(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: (period) {
                setState(() {
                  _selectedPeriod = period;
                  _loadDataForPeriod();
                });
              },
            ),
            const SizedBox(height: 20),

            // Course selector (tap text links)
            CourseSelector(
              selectedCourse: _selectedCourse,
              onCourseSelected: (course) {
                setState(() {
                  _selectedCourse = course;
                  _updateWeights();
                });
                _persistSelectedCourse();
                // Don't recalculate/save when switching courses - just load display grades
                _loadDataForPeriod(
                  shouldSaveGrade: false,
                  reloadExamData: false,
                );
              },
            ),
            const SizedBox(height: 20),

            // Quizzes section
            QuizSection(
              quizzes: _quizzes,
              average: _quizAverage,
              weighted: _quizWeighted,
              weight: _quizWeight,
              onEdit: () {
                _openQuizEditScreen();
              },
            ),
            const SizedBox(height: 16),

            // Graded Oral section
            GradedOralSection(
              score: _oralScore,
              maxScore: _oralMaxScore,
              date: _oralDate,
              weight: _oralWeight,
              onEdit: () {
                _openGradedOralEditScreen();
              },
            ),
            const SizedBox(height: 16),

            // Hands-on section
            if (_selectedCourse == 'lab') ...[
              HandsOnSection(
                activities: _handsOn,
                average: _handsOnAverage,
                weighted: _handsOnWeighted,
                weight: _handsOnWeight,
                onAdd: () {
                  _openHandsOnEditScreen();
                },
                onEdit: () {
                  _openHandsOnEditScreen();
                },
              ),
              const SizedBox(height: 16),
            ],

            // Project section
            ProjectSection(
              score: _projectScore,
              maxScore: _projectMaxScore,
              date: _projectDate,
              title: _projectTitle,
              feedback: _projectFeedback,
              weight: _projectWeight,
              onEdit: () {
                _openProjectEditScreen();
              },
            ),
            const SizedBox(height: 16),

            // Exam section
            ExamSection(
              codingScore: _codingScore,
              writtenScore: _writtenScore,
              maxScore: 50,
              codingDate: _codingDate,
              writtenDate: _writtenDate,
              average: _examAverage,
              weighted: _examWeighted,
              course: _selectedCourse,
              weight: _examWeight,
              onViewCode: () async {
                try {
                  final submissionDoc = await _firestore
                      .collection('codingExamAnswerByStudent')
                      .doc(widget.studentId)
                      .get();

                  if (!submissionDoc.exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No coding submissions found'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final submission = StudentSubmission.fromFirestore(
                    submissionDoc.data() as Map<String, dynamic>,
                    submissionDoc.id,
                  );

                  final updatedSubmission = await Navigator.push<StudentSubmission>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentSubmissionView(
                        submission: submission,
                        onSave: (updated) async {
                          // Save the updated submission to Firestore
                          try {
                            await _firestore
                                .collection('codingExamAnswerByStudent')
                                .doc(widget.studentId)
                                .update({
                                  'answers': updated.answers
                                      .map(
                                        (answer) => {
                                          'questionId': answer.questionId,
                                          'difficulty': answer.difficulty,
                                          'code': answer.code,
                                          'submittedAt': answer.submittedAt,
                                          'score': answer.score,
                                          'feedback': answer.feedback,
                                        },
                                      )
                                      .toList(),
                                  'totalScore': updated.totalScore,
                                  'status': updated.status,
                                  'gradedAt': FieldValue.serverTimestamp(),
                                });

                            print(
                              '✅ Submission updated for ${updated.studentName}',
                            );
                            print('📊 New total score: ${updated.totalScore}');

                            // Reload data to reflect changes
                            await _loadDataForPeriod();
                          } catch (e) {
                            print('❌ Error saving submission: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error saving: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );

                  // Show success message if submission was updated
                  if (updatedSubmission != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Submission updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              onRegrade: () {
                // TODO: Open regrade dialog
              },
              onEditWritten: () {
                _openEditWrittenScreen();
              },
            ),
            const SizedBox(height: 16),

            // Final computation
            FinalComputationCard(
              totalPercentage: _totalPercentage,
              grade: _finalGrade,
              status: _status,
            ),
          ],
        ),
      ),
    );
  }
}
