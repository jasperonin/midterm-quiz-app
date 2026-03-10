// lib/models/grade_record.dart
import 'package:flutter/material.dart';

class GradeRecord {
  final String studentId;
  final String studentName;
  final String section;
  final int prelim;
  final int midterm;
  final int finals;
  final int total;
  final double gwa;
  final String status;
  final String remarks;

  GradeRecord({
    required this.studentId,
    required this.studentName,
    required this.section,
    required this.prelim,
    required this.midterm,
    required this.finals,
    required this.total,
    required this.gwa,
    required this.status,
    required this.remarks,
  });

  // Computed properties
  String get gradeLetter {
    if (gwa >= 90) return 'A';
    if (gwa >= 80) return 'B';
    if (gwa >= 75) return 'C';
    if (gwa >= 70) return 'D';
    return 'F';
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'passed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'incomplete':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Factory method to create from JSON (for mock data)
  factory GradeRecord.fromJson(Map<String, dynamic> json) {
    return GradeRecord(
      studentId: json['studentId'],
      studentName: json['studentName'],
      section: json['section'],
      prelim: json['prelim'],
      midterm: json['midterm'],
      finals: json['finals'],
      total: json['total'],
      gwa: json['gwa'].toDouble(),
      status: json['status'],
      remarks: json['remarks'],
    );
  }

  // For creating mock data
  static List<GradeRecord> get mockData {
    return [
      GradeRecord(
        studentId: '2024-001',
        studentName: 'John Doe',
        section: 'BSIT_4D',
        prelim: 85,
        midterm: 78,
        finals: 92,
        total: 255,
        gwa: 85.0,
        status: 'Passed',
        remarks: 'Good performance',
      ),
      GradeRecord(
        studentId: '2024-002',
        studentName: 'Jane Smith',
        section: 'BSIT_4D',
        prelim: 92,
        midterm: 88,
        finals: 94,
        total: 274,
        gwa: 91.3,
        status: 'Passed',
        remarks: 'Excellent',
      ),
      GradeRecord(
        studentId: '2024-003',
        studentName: 'Bob Johnson',
        section: 'BSIT_4D',
        prelim: 65,
        midterm: 70,
        finals: 68,
        total: 203,
        gwa: 67.7,
        status: 'Failed',
        remarks: 'Needs improvement',
      ),
    ];
  }
}
