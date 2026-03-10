// lib/screens/teacher/teacher_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/student_submission.dart';
import '../../widgets/teacher/student_submission.dart';
import 'student_submission.dart';
import 'attendance_tab.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Coding Exam', icon: Icon(Icons.grading)),
            Tab(text: 'Grades', icon: Icon(Icons.book)),
          ],
        ),
        // No actions - removed filter and search icons
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGradingTab(),
                AttendanceTab(parentConstraints: constraints),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradingTab() {
    return Container(
      color: Colors.grey.shade50,
      child: StreamBuilder<QuerySnapshot>(
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

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          try {
            List<StudentSubmission> submissions = snapshot.data!.docs
                .map((doc) {
                  try {
                    return StudentSubmission.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );
                  } catch (e) {
                    print('Error parsing document ${doc.id}: $e');
                    return null;
                  }
                })
                .where((sub) => sub != null && sub.answers.isNotEmpty)
                .cast<StudentSubmission>()
                .toList();

            if (submissions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No submissions yet'),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Stats cards
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Total',
                        submissions.length,
                        Icons.people,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Submitted',
                        submissions
                            .where((s) => s.status == 'submitted')
                            .length,
                        Icons.send,
                        Colors.purple,
                      ),
                      _buildStatCard(
                        'Graded',
                        submissions.where((s) => s.status == 'graded').length,
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      return StudentSubmissionCard(
                        submission: submissions[index],
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentSubmissionView(
                                submission: submissions[index],
                                onSave: (updated) {
                                  _updateSubmission(updated);
                                },
                              ),
                            ),
                          );

                          if (result != null && mounted) {
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          } catch (e) {
            print('Error building list: $e');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading submissions'),
                ],
              ),
            );
          }
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved grades for ${submission.studentName}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
