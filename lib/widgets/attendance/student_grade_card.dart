// lib/widgets/attendance/student_grade_card.dart
import 'package:flutter/material.dart';
import '../../models/grade_record.dart';
import 'grade_cell.dart';

class StudentGradeCard extends StatelessWidget {
  final GradeRecord record;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const StudentGradeCard({
    Key? key,
    required this.record,
    required this.onTap,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student info row
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.teal.shade100,
                    child: Text(
                      record.studentName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.studentName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${record.studentId} • ${record.section}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: record.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: record.statusColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      record.status,
                      style: TextStyle(
                        color: record.statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Grade cells row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GradeCell(
                    label: 'Prelim',
                    score: record.prelim,
                    color: record.prelim >= 75 ? Colors.green : Colors.red,
                    isEditable: true,
                    onTap: onEdit,
                  ),
                  GradeCell(
                    label: 'Midterm',
                    score: record.midterm,
                    color: record.midterm >= 75 ? Colors.green : Colors.red,
                    isEditable: true,
                    onTap: onEdit,
                  ),
                  GradeCell(
                    label: 'Finals',
                    score: record.finals,
                    color: record.finals >= 75 ? Colors.green : Colors.red,
                    isEditable: true,
                    onTap: onEdit,
                  ),
                  GradeCell(
                    label: 'Total',
                    score: record.total,
                    color: Colors.blue,
                  ),
                  GradeCell(
                    label: 'GWA',
                    score: record.gwa.round(),
                    color: Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Remarks and details button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Remarks: ${record.remarks}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(foregroundColor: Colors.teal),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
