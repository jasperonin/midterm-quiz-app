// lib/scripts/migrate_user_scores.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';

class MigrateUserScores {
  static Future<void> migrate() async {
    print('🚀 Starting user scores migration...');
    print('═══════════════════════════════════════════');

    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized');

      // Get all users
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      print('📊 Found ${usersSnapshot.docs.length} users to migrate');

      int successCount = 0;
      int failCount = 0;
      int migratedQuizScores = 0;

      // Use batch for efficient updates
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int operationCount = 0;

      for (var userDoc in usersSnapshot.docs) {
        try {
          Map<String, dynamic> userData = userDoc.data();

          // Get existing scores array (if any)
          List<dynamic> existingScores = userData['scores'] ?? [];

          // Prepare new structure
          Map<String, dynamic> updateData = {
            // Initialize new score structure
            'scores': {
              'quizScores':
                  existingScores, // Migrate existing scores to quizScores
              'majorExamScores': {
                'written': [], // Empty array for written scores
                'coding': [], // Empty array for coding scores
              },
            },

            // Initialize stats
            'stats': {
              'totalQuizzesTaken': existingScores.length,
              'averageQuizScore': _calculateAverage(existingScores),
              'totalMajorExamsTaken': 0,
              'averageMajorExamScore': 0.0,
              'lastActive':
                  userData['lastActive'] ?? FieldValue.serverTimestamp(),
            },

            // Ensure existing fields are preserved
            'examStatus': userData['examStatus'] ?? 'inactive',
            'hasTakenExam': userData['hasTakenExam'] ?? false,
            'tabSwitchCount': userData['tabSwitchCount'] ?? 0,
            'lastMigration': FieldValue.serverTimestamp(),
          };

          // Add to batch
          batch.update(userDoc.reference, updateData);
          operationCount++;
          successCount++;
          migratedQuizScores += existingScores.length;

          print(
            '📝 Migrated user: ${userDoc.id} (${existingScores.length} quiz scores)',
          );

          // Firestore batch limit is 500 operations
          if (operationCount >= 400) {
            await batch.commit();
            print('✅ Committed batch of $operationCount updates');
            batch = FirebaseFirestore.instance.batch();
            operationCount = 0;
          }
        } catch (e) {
          print('❌ Failed to migrate user ${userDoc.id}: $e');
          failCount++;
        }
      }

      // Commit remaining updates
      if (operationCount > 0) {
        await batch.commit();
        print('✅ Committed final batch of $operationCount updates');
      }

      print('═══════════════════════════════════════════');
      print('✅ MIGRATION COMPLETE!');
      print('📊 Users migrated: $successCount');
      if (failCount > 0) {
        print('❌ Failed: $failCount users');
      }
      print('📊 Total quiz scores migrated: $migratedQuizScores');
      print('📋 New structure added:');
      print('   • scores.quizScores (contains existing scores)');
      print('   • scores.majorExamScores.written (empty array)');
      print('   • scores.majorExamScores.coding (empty array)');
      print('   • stats object with aggregated data');
      print('═══════════════════════════════════════════');
    } catch (e) {
      print('❌ FATAL ERROR: $e');
      print('═══════════════════════════════════════════');
    }
  }

  static double _calculateAverage(List<dynamic> scores) {
    if (scores.isEmpty) return 0.0;

    double total = 0;
    int count = 0;

    for (var score in scores) {
      if (score is Map && score.containsKey('percentage')) {
        total += (score['percentage'] as num).toDouble();
        count++;
      }
    }

    return count > 0 ? total / count : 0.0;
  }
}

void main() async {
  print('🔄 Starting migration script...');
  print('⚠️  Make sure you have a backup of your Firestore database!');
  print('⏳ This may take a few minutes...\n');

  WidgetsFlutterBinding.ensureInitialized();
  await MigrateUserScores.migrate();
}
