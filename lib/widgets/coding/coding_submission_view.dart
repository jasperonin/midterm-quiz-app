// lib/widgets/student/coding_submissions_view.dart
import 'package:app/screens/teacher/student_submission.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/student_submission.dart';

class CodingSubmissionsView extends StatelessWidget {
  final String studentId;
  final bool showStatsCards;

  const CodingSubmissionsView({
    super.key,
    required this.studentId,
    this.showStatsCards = true,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('codingExamAnswerByStudent')
          .doc(studentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final doc = snapshot.data;
        if (doc == null || !doc.exists) {
          return const Center(child: Text('No coding submissions found'));
        }

        final submission = StudentSubmission.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        if (submission.answers.isEmpty) {
          return const Center(child: Text('No answers submitted yet'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            if (showStatsCards) ...[
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Score',
                      '${submission.totalScore}',
                      Icons.score,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Status',
                      submission.status.toUpperCase(),
                      Icons.check_circle,
                      submission.status == 'graded'
                          ? Colors.green
                          : Colors.orange,
                    ),
                    _buildStatCard(
                      'Answers',
                      submission.answers.length.toString(),
                      Icons.quiz,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Answers list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: submission.answers.length,
                itemBuilder: (context, index) {
                  final answer = submission.answers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(color: Colors.teal.shade800),
                        ),
                      ),
                      title: Text(
                        'Question ${answer.questionId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Difficulty: ${answer.difficulty.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getDifficultyColor(answer.difficulty),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            answer.code.length > 100
                                ? '${answer.code.substring(0, 100)}...'
                                : answer.code,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: answer.score != null
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          answer.score != null
                              ? '${answer.score} pts'
                              : 'Pending',
                          style: TextStyle(
                            color: answer.score != null
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      onTap: () {
                        // Navigate to full submission view
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentSubmissionView(
                              submission: submission,
                              onSave: (updated) {
                                // Handle save if needed
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
          value,
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
