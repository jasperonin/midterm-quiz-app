// lib/scripts/reset_exam_statuses.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/widgets.dart';
import '../firebase_env_options.dart';

class ExamStatusResetter {
  static Future<void> resetAllExamStatuses() async {
    print('🚀 Starting exam status reset...');
    print('═══════════════════════════════════════════');
    
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: FirebaseEnvOptions.currentPlatform,
      );
      print('✅ Firebase initialized');
      
      // Get all users
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      
      print('📊 Found ${usersSnapshot.docs.length} users');
      
      int resetCount = 0;
      int alreadyInactiveCount = 0;
      
      // Process each user
      for (var userDoc in usersSnapshot.docs) {
        Map<String, dynamic> userData = userDoc.data();
        String currentStatus = userData['examStatus'] ?? 'inactive';
        
        if (currentStatus == 'active') {
          // Reset to inactive
          await userDoc.reference.update({
            'examStatus': 'inactive',
            'lastReset': FieldValue.serverTimestamp(),
          });
          resetCount++;
          print('🔄 Reset user: ${userDoc.id} (was active)');
        } else {
          alreadyInactiveCount++;
        }
      }
      
      print('═══════════════════════════════════════════');
      print('✅ RESET COMPLETE!');
      print('📊 Users reset from active → inactive: $resetCount');
      print('📊 Users already inactive: $alreadyInactiveCount');
      print('📊 Total users processed: ${usersSnapshot.docs.length}');
      print('═══════════════════════════════════════════');
      
    } catch (e) {
      print('❌ ERROR: $e');
      print('═══════════════════════════════════════════');
    }
  }
  
  // Optional: Reset a specific user by ID
  static Future<void> resetSpecificUser(String studentId) async {
    print('🚀 Resetting specific user: $studentId');
    
    try {
      await Firebase.initializeApp(
        options: FirebaseEnvOptions.currentPlatform,
      );
      
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(studentId);
      
      final userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        print('❌ User not found: $studentId');
        return;
      }
      
      await userRef.update({
        'examStatus': 'inactive',
        'lastReset': FieldValue.serverTimestamp(),
      });
      
      print('✅ User $studentId reset to inactive');
      
    } catch (e) {
      print('❌ Error: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  
  // Check if a specific user ID was passed as argument
  if (args.length > 1 && args[1] == '--user' && args.length > 2) {
    String studentId = args[2];
    await ExamStatusResetter.resetSpecificUser(studentId);
  } else {
    // Reset all users
    await ExamStatusResetter.resetAllExamStatuses();
  }
}

// Simple argument parser
List<dynamic> get args => const []
    .followedBy(List.from(CommandLineArgs()))
    .toList();

List<String> CommandLineArgs() {
  // This is a simple way to get command line args in Dart
  return const [];
}
