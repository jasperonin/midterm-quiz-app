// lib/scripts/assign_period_to_scores.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('🚀 Assigning periods to existing quiz scores...');
  print('═══════════════════════════════════════════');

  try {
    // First, get the academic calendar settings
    final settingsDoc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('academicCalendar')
        .get();

    if (!settingsDoc.exists) {
      print(
        '❌ Academic calendar not found. Please run migrate_academic_calendar.dart first.',
      );
      return;
    }

    final terms = settingsDoc.data()?['terms'];
    final midtermStart = (terms?['midterm']['startDate'] as Timestamp).toDate();
    final midtermEnd = (terms?['midterm']['endDate'] as Timestamp).toDate();
    final finalsStart = (terms?['finals']['startDate'] as Timestamp).toDate();
    final finalsEnd = (terms?['finals']['endDate'] as Timestamp).toDate();

    print(
      '📅 Midterm period: ${_formatDate(midtermStart)} - ${_formatDate(midtermEnd)}',
    );
    print(
      '📅 Finals period: ${_formatDate(finalsStart)} - ${_formatDate(finalsEnd)}',
    );
    print('═══════════════════════════════════════════');

    // Get all users
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    print('📊 Found ${usersSnapshot.docs.length} users');

    int updatedUsers = 0;
    int updatedScores = 0;
    int skippedScores = 0;

    // Process each user
    for (var userDoc in usersSnapshot.docs) {
      final data = userDoc.data();
      final scores = data['scores'];

      if (scores == null) continue;

      final quizScores = scores['quizScores'];
      if (quizScores == null || quizScores.isEmpty) continue;

      bool userUpdated = false;
      List<dynamic> updatedQuizScores = [];

      for (var quiz in quizScores) {
        final quizMap = Map.from(quiz);

        // Skip if already has period
        if (quizMap.containsKey('period')) {
          updatedQuizScores.add(quizMap);
          skippedScores++;
          continue;
        }

        // Get completion date
        DateTime? completionDate;
        if (quizMap['completedAt'] != null) {
          if (quizMap['completedAt'] is String) {
            completionDate = DateTime.parse(quizMap['completedAt']);
          } else if (quizMap['completedAt'] is Timestamp) {
            completionDate = (quizMap['completedAt'] as Timestamp).toDate();
          }
        }

        if (completionDate == null) {
          // No date, default to midterm
          quizMap['period'] = 'midterm';
          print('⚠️ No date for quiz in ${userDoc.id}, defaulting to midterm');
        } else {
          // Determine period based on date
          if (_isDateInRange(completionDate, midtermStart, midtermEnd)) {
            quizMap['period'] = 'midterm';
          } else if (_isDateInRange(completionDate, finalsStart, finalsEnd)) {
            quizMap['period'] = 'finals';
          } else {
            // Outside both ranges, default to midterm
            quizMap['period'] = 'midterm';
            print(
              '⚠️ Date outside ranges for ${userDoc.id}: ${_formatDate(completionDate)}, defaulting to midterm',
            );
          }
        }

        updatedQuizScores.add(quizMap);
        updatedScores++;
        userUpdated = true;
      }

      if (userUpdated) {
        await userDoc.reference.update({
          'scores.quizScores': updatedQuizScores,
          'lastPeriodAssignment': FieldValue.serverTimestamp(),
        });
        updatedUsers++;
        print('✅ Updated ${userDoc.id}: ${updatedScores} scores processed');
      }
    }

    print('═══════════════════════════════════════════');
    print('✅ MIGRATION COMPLETE!');
    print('📊 Users updated: $updatedUsers');
    print('📊 Scores updated: $updatedScores');
    print('📊 Scores already had period: $skippedScores');
    print('═══════════════════════════════════════════');
  } catch (e) {
    print('❌ ERROR: $e');
    print('═══════════════════════════════════════════');
  }
}

bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
  // Compare only dates, ignore time
  final dateOnly = DateTime(date.year, date.month, date.day);
  final startOnly = DateTime(start.year, start.month, start.day);
  final endOnly = DateTime(end.year, end.month, end.day);

  return dateOnly.isAfter(startOnly.subtract(const Duration(days: 1))) &&
      dateOnly.isBefore(endOnly.add(const Duration(days: 1)));
}

String _formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}
