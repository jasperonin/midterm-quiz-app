// lib/scripts/export_users_csv.dart
import 'dart:convert';
import 'dart:html' as html; // For web download
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('🚀 Starting user data export...');

  try {
    // Fetch all users
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    print('📊 Found ${usersSnapshot.docs.length} users');

    // Create CSV content
    List<String> csvRows = [];

    // Add CSV header
    csvRows.add(
      [
        'student_id',
        'name',
        'exam_status',
        'has_taken_exam',
        'tab_switch_count',
        'total_quiz_scores',
        'average_quiz_percentage',
        'written_scores',
        'coding_scores',
        'total_major_exam_score',
        'last_active',
        'created_at',
      ].join(','),
    );

    // Process each user
    for (var doc in usersSnapshot.docs) {
      try {
        final data = doc.data();

        // Helper function to safely convert any value to string
        String safeString(dynamic value, {String defaultValue = ''}) {
          if (value == null) return defaultValue;
          try {
            if (value is String) return value;
            if (value is num) return value.toString();
            if (value is bool) return value.toString();
            if (value is Timestamp) return value.toDate().toIso8601String();
            if (value is DateTime) return value.toIso8601String();
            if (value is Map || value is List) return jsonEncode(value);
            return value.toString();
          } catch (e) {
            return defaultValue;
          }
        }

        // Safely extract data with type checking
        String name = safeString(data['name']).replaceAll(',', ' ');
        String examStatus = safeString(
          data['examStatus'],
          defaultValue: 'inactive',
        );
        String hasTakenExam = safeString(
          data['hasTakenExam'],
          defaultValue: 'false',
        );
        String tabSwitchCount = safeString(
          data['tabSwitchCount'],
          defaultValue: '0',
        );

        // Handle scores
        dynamic scoresData = data['scores'];
        Map<String, dynamic> scores = {};
        if (scoresData is Map) scores = Map.from(scoresData);

        // Handle quizScores
        List<dynamic> quizScoresList = [];
        dynamic quizScoresData = scores['quizScores'];
        if (quizScoresData is List) quizScoresList = List.from(quizScoresData);

        // Handle majorExamScores
        Map<String, dynamic> majorExamScores = {};
        dynamic majorExamData = scores['majorExamScores'];
        if (majorExamData is Map) majorExamScores = Map.from(majorExamData);

        // Get written and coding scores
        List<dynamic> writtenScores = [];
        dynamic writtenData = majorExamScores['written'];
        if (writtenData is List) writtenScores = List.from(writtenData);

        List<dynamic> codingScores = [];
        dynamic codingData = majorExamScores['coding'];
        if (codingData is List) codingScores = List.from(codingData);

        // Calculate quiz statistics
        int totalQuizScores = quizScoresList.length;
        double totalQuizPercentage = 0;

        for (var quiz in quizScoresList) {
          if (quiz is Map) {
            var percentage = quiz['percentage'];
            if (percentage is num) totalQuizPercentage += percentage.toDouble();
          }
        }

        double avgQuizPercentage = totalQuizScores > 0
            ? totalQuizPercentage / totalQuizScores
            : 0;

        // Calculate major exam totals
        int writtenTotal = 0;
        for (var w in writtenScores) {
          if (w is Map) {
            var score = w['score'];
            if (score is num) writtenTotal += score.toInt();
          }
        }

        int codingTotal = 0;
        for (var c in codingScores) {
          if (c is Map) {
            var score = c['score'];
            if (score is num) codingTotal += score.toInt();
          }
        }

        // Handle timestamps
        String lastActive = safeString(data['lastActive']);
        String createdAt = safeString(data['createdAt']);

        // Create CSV row
        csvRows.add(
          [
            doc.id,
            '"$name"',
            examStatus,
            hasTakenExam,
            tabSwitchCount,
            totalQuizScores.toString(),
            avgQuizPercentage.toStringAsFixed(2),
            writtenTotal.toString(),
            codingTotal.toString(),
            (writtenTotal + codingTotal).toString(),
            lastActive,
            createdAt,
          ].join(','),
        );

        print('✅ Processed: ${doc.id} - $name');
      } catch (e) {
        print('❌ Error processing user ${doc.id}: $e');
        csvRows.add(
          [
            doc.id,
            '"ERROR"',
            'error',
            'false',
            '0',
            '0',
            '0',
            '0',
            '0',
            '0',
            '',
            '',
          ].join(','),
        );
      }
    }

    // Convert to blob and trigger download
    final csvContent = csvRows.join('\n');
    final blob = html.Blob([csvContent], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute(
        'download',
        'user_export_${DateTime.now().toIso8601String()}.csv',
      )
      ..click();

    html.Url.revokeObjectUrl(url);

    print('✅ Export complete!');
    print('📊 Total rows: ${csvRows.length - 1}');
    print('💾 File download triggered in browser');
  } catch (e) {
    print('❌ Fatal error: $e');
  }
}
