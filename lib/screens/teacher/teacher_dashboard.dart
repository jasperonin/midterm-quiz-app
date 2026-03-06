// lib/screens/teacher/teacher_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/student_submission.dart';
import '../../widgets/teacher/student_submission.dart';
import 'student_submission.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, pending, submitted, graded

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          // Filter dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Students')),
              const PopupMenuItem(value: 'pending', child: Text('Not Started')),
              const PopupMenuItem(
                value: 'submitted',
                child: Text('Awaiting Grade'),
              ),
              const PopupMenuItem(value: 'graded', child: Text('Graded')),
            ],
          ),
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: // In teacher_dashboard.dart, update the StreamBuilder section:
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('codingExamAnswerByStudent')
            .orderBy('studentName')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Convert to submissions and filter out those with no answers
          List<StudentSubmission> allSubmissions = snapshot.data!.docs
              .map(
                (doc) => StudentSubmission.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

          // 👇 FILTER: Only show students who have submitted answers
          List<StudentSubmission> submissionsWithAnswers = allSubmissions
              .where(
                (sub) => sub.answers.isNotEmpty,
              ) // Only show if they have answers
              .toList();

          // Apply status filter
          if (_filterStatus != 'all') {
            submissionsWithAnswers = submissionsWithAnswers
                .where((sub) => sub.status == _filterStatus)
                .toList();
          }

          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            submissionsWithAnswers = submissionsWithAnswers.where((sub) {
              return sub.studentName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  sub.studentId.contains(_searchQuery);
            }).toList();
          }

          // Update stats based on filtered submissions
          int totalWithAnswers = submissionsWithAnswers.length;
          int submitted = submissionsWithAnswers
              .where((s) => s.status == 'submitted')
              .length;
          int graded = submissionsWithAnswers
              .where((s) => s.status == 'graded')
              .length;

          if (submissionsWithAnswers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No submissions yet'
                        : 'No matching students',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  if (_searchQuery.isEmpty)
                    const Text(
                      'Students who haven\'t started are not shown',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats cards (updated counts)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Total',
                      totalWithAnswers,
                      Icons.people,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Submitted',
                      submitted,
                      Icons.send,
                      Colors.purple,
                    ),
                    _buildStatCard(
                      'Graded',
                      graded,
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ],
                ),
              ),

              // Submissions list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: submissionsWithAnswers.length,
                  itemBuilder: (context, index) {
                    final submission = submissionsWithAnswers[index];
                    return StudentSubmissionCard(
                      submission: submission,
                      onTap: () async {
                        final _ = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentSubmissionView(
                              submission: submission,
                              onSave: (updated) {
                                _updateSubmission(updated);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Student'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter name or ID',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value.trim();
            });
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSubmission(StudentSubmission submission) async {
    try {
      await FirebaseFirestore.instance
          .collection('codingExamAnswerByStudent')
          .doc(submission.studentId)
          .update({
            'answers': submission.answers.map((a) => a.toJson()).toList(),
            'status': submission.status,
            'totalScore': submission.totalScore,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      print('✅ Updated submission for ${submission.studentId}');
    } catch (e) {
      print('❌ Error updating submission: $e');
    }
  }
}
