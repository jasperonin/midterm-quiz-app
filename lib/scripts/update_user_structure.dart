// lib/scripts/update_user_structure.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';

class UserStructureUpdater {
  static Future<void> updateAllUsers() async {
    print('🚀 Starting user structure update...');
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

      print('📊 Found ${usersSnapshot.docs.length} users to update');

      int updatedCount = 0;

      // Process each user
      for (var userDoc in usersSnapshot.docs) {
        print('─────────────────────────────────────────');
        print('📝 Processing user: ${userDoc.id}');

        // Get existing data
        Map<String, dynamic> existingData = userDoc.data();

        // Prepare new structure with all fields
        Map<String, dynamic> updatedData = {
          'name': existingData['last_name'] ?? '',
          'scores': existingData['scores'] ?? [], // Keep existing scores if any
          'examStatus':
              'inactive', // Default: inactive (0 = inactive, 1 = active)
          'createdAt':
              existingData['createdAt'] ?? FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Remove old fields if they exist
        await userDoc.reference.set(updatedData, SetOptions(merge: false));

        updatedCount++;
        print('✅ Updated user: ${userDoc.id}');
      }

      print('═══════════════════════════════════════════');
      print('✅ UPDATE COMPLETE!');
      print('📊 Users updated: $updatedCount');
      print('📊 New fields added: examStatus (inactive)');
      print('═══════════════════════════════════════════');
    } catch (e) {
      print('❌ ERROR: $e');
      print('═══════════════════════════════════════════');
    }
  }

  // Optional: Reset all exam statuses (run this if someone gets stuck)
  static Future<void> resetAllExamStatuses() async {
    print('🚀 Resetting all exam statuses...');

    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    for (var userDoc in usersSnapshot.docs) {
      await userDoc.reference.update({'examStatus': 'inactive'});
    }

    print('✅ All exam statuses reset to inactive');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserStructureUpdater.updateAllUsers();
}
