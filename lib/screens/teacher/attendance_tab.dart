// lib/screens/teacher/attendance_tab.dart
import 'package:flutter/material.dart';
import '../../models/grade_record.dart';
import '../../widgets/attendance/semester_selector.dart';
import '../../widgets/attendance/grade_summary_header.dart';
import '../../widgets/attendance/student_grade_card.dart';

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({Key? key, required BoxConstraints parentConstraints}) : super(key: key);

  @override
  _AttendanceTabState createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  final List<String> semesters = [
    '1st Sem 2024',
    '2nd Sem 2024',
    'Summer 2024',
  ];
  final List<String> sections = ['BSIT_4D', 'BSIT_4A', 'BSIT_4B', 'BSIT_4C'];

  String _selectedSemester = '2nd Sem 2024';
  String _selectedSection = 'BSIT_4D';
  String _searchQuery = '';

  List<GradeRecord> get _filteredRecords {
    return GradeRecord.mockData
        .where((record) => record.section == _selectedSection)
        .where((record) {
          if (_searchQuery.isEmpty) return true;
          return record.studentName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              record.studentId.contains(_searchQuery);
        })
        .toList();
  }

  int get _totalStudents => _filteredRecords.length;
  int get _completed =>
      _filteredRecords.where((r) => r.status != 'Incomplete').length;
  int get _pending =>
      _filteredRecords.where((r) => r.status == 'Incomplete').length;
  int get _passed => _filteredRecords.where((r) => r.status == 'Passed').length;
  int get _failed => _filteredRecords.where((r) => r.status == 'Failed').length;

  void _showEditDialog(GradeRecord record) {
    // For now, just show a placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Grades - ${record.studentName}'),
        content: const Text('Grade editing will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search student by name or ID...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Semester selector
          SemesterSelector(
            semesters: semesters,
            selectedSemester: _selectedSemester,
            onSemesterChanged: (value) {
              setState(() {
                _selectedSemester = value;
              });
            },
            sections: sections,
            selectedSection: _selectedSection,
            onSectionChanged: (value) {
              setState(() {
                _selectedSection = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Summary header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GradeSummaryHeader(
              totalStudents: _totalStudents,
              completed: _completed,
              pending: _pending,
              passed: _passed,
              failed: _failed,
            ),
          ),

          const SizedBox(height: 16),

          // Student list
          Expanded(
            child: _filteredRecords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No students in this section'
                              : 'No matching students',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredRecords.length,
                    itemBuilder: (context, index) {
                      return StudentGradeCard(
                        record: _filteredRecords[index],
                        onTap: () {
                          // Navigate to detailed view
                          _showEditDialog(_filteredRecords[index]);
                        },
                        onEdit: () {
                          _showEditDialog(_filteredRecords[index]);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
