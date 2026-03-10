// lib/scripts/reset_all_users.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';

class ResetAllUsers {
  static Future<void> reset() async {
    print('🚀 Starting bulk user reset...');
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
      
      print('📊 Found ${usersSnapshot.docs.length} users to reset');
      
      int successCount = 0;
      int failCount = 0;
      
      // Use batch for efficient updates (max 500 per batch)
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int operationCount = 0;
      
      for (var userDoc in usersSnapshot.docs) {
        try {
          // Prepare reset data
          Map<String, dynamic> resetData = {
            'examStatus': 'inactive',
            'hasTakenExam': false,
            'tabSwitchCount': 0,
            'scores': {'quizScores':[]},
            'isCurrentlyTakingCoding':false,
            'isCurrentlyTakingWritten':false,
            'stats': {'averageQuizScore': 0,'totalQuizzesTaken':0,},
            'totalScore':0,
            'writtenScore':0,
            'lastReset': FieldValue.serverTimestamp(),
          };
          
          // Add to batch
          batch.update(userDoc.reference, resetData);
          operationCount++;
          successCount++;
          
          // Firestore batch limit is 500 operations
          if (operationCount >= 400) {
            await batch.commit();
            print('✅ Committed batch of $operationCount updates');
            batch = FirebaseFirestore.instance.batch();
            operationCount = 0;
          }
          
        } catch (e) {
          print('❌ Failed to reset user ${userDoc.id}: $e');
          failCount++;
        }
      }
      
      // Commit remaining updates
      if (operationCount > 0) {
        await batch.commit();
        print('✅ Committed final batch of $operationCount updates');
      }
      
      print('═══════════════════════════════════════════');
      print('✅ RESET COMPLETE!');
      print('📊 Successful: $successCount users');
      if (failCount > 0) {
        print('❌ Failed: $failCount users');
      }
      print('📋 Fields reset:');
      print('   • examStatus → inactive');
      print('   • hasTakenExam → false');
      print('   • tabSwitchCount → 0');
      print('═══════════════════════════════════════════');
      
    } catch (e) {
      print('❌ FATAL ERROR: $e');
      print('═══════════════════════════════════════════');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ResetAllUsers.reset();
}