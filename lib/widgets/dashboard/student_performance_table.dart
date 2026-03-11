// lib/modules/dashboard/widgets/student_performance_table.dart
import 'package:app/core/constants/app_enums.dart';
import 'package:flutter/material.dart';
import '../../models/dashboard_data.dart';
import '../../core/utils/number_fomatter.dart';

class StudentPerformanceTable extends StatefulWidget {
  final List<StudentPerformance> students;
  final VoidCallback onLoadMore;
  final bool hasMore;

  const StudentPerformanceTable({
    Key? key,
    required this.students,
    required this.onLoadMore,
    required this.hasMore,
  }) : super(key: key);

  @override
  State<StudentPerformanceTable> createState() =>
      _StudentPerformanceTableState();
}

class _StudentPerformanceTableState extends State<StudentPerformanceTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (widget.hasMore) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Student Performance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
          ),

          const Divider(height: 1),

          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Student',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Avg. Score',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Quizzes',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: widget.students.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    itemCount:
                        widget.students.length + (widget.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == widget.students.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final student = widget.students[index];
                      return _buildStudentRow(student);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRow(StudentPerformance student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _getAvatarColor(student.averageScore),
                  child: Text(
                    student.studentName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'ID: ${student.studentId}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              NumberFormatter.formatPercentage(student.averageScore),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _getScoreColor(student.averageScore),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              student.quizzesTaken.toString(),
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: _buildStatusChip(student.status)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(StudentStatus status) {
    Color color;
    String label;

    switch (status) {
      case StudentStatus.active:
        color = Colors.green;
        label = 'Active';
        break;
      case StudentStatus.inactive:
        color = Colors.grey;
        label = 'Inactive';
        break;
      case StudentStatus.atRisk:
        color = Colors.orange;
        label = 'At Risk';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Color _getAvatarColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green.shade700;
    if (score >= 75) return Colors.blue.shade700;
    if (score >= 60) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No student data available',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
