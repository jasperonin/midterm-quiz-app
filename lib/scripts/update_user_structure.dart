// lib/scripts/update_user_structure.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';

class UserStructureUpdater {
  static Future<void> updateAllUsers() async {
    final List<Map<String, dynamic>> users = [
      {'id': '5250531', 'name': 'Amahan'},
      {'id': '5250583', 'name': 'Amancio'},
      {'id': '5250572', 'name': 'Ancajas'},
      {'id': '5250517', 'name': 'Arias'},
      {'id': '5250605', 'name': 'Arnado'},
      {'id': '5251886', 'name': 'Brigoli'},
      {'id': '5250562', 'name': 'Camahalan'},
      {'id': '5250539', 'name': 'Camus'},
      {'id': '5250535', 'name': 'Candado'},
      {'id': '5250549', 'name': 'Cañete'},
      {'id': '5250568', 'name': 'Canoy'},
      {'id': '5250581', 'name': 'Capuyan'},
      {'id': '5250579', 'name': 'Claro'},
      {'id': '5250528', 'name': 'Dañas'},
      {'id': '5250574', 'name': 'Dalogdog'},
      {'id': '5251880', 'name': 'Dinopol'},
      {'id': '5241367', 'name': 'Fortunado'},
      {'id': '5250610', 'name': 'Gungob'},
      {'id': '5250564', 'name': 'Kinkito'},
      {'id': '5250542', 'name': 'Labangon'},
      {'id': '5251884', 'name': 'Lariosa'},
      {'id': '5250529', 'name': 'Libre'},
      {'id': '5250606', 'name': 'Muños'},
      {'id': '5251950', 'name': 'Navales'},
      {'id': '5251883', 'name': 'Paglinawan'},
      {'id': '5251882', 'name': 'Pegarom'},
      {'id': '5250545', 'name': 'Pones'},
      {'id': '5250525', 'name': 'Tan'},
      {'id': '5250435', 'name': 'Uy'},
      {'id': '5250532', 'name': 'Villanueva'},
      {'id': '5250552', 'name': 'Ylanan'},
    ];
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
            'name': users.firstWhere(
            (user) => user['id'] == userDoc.id,
            orElse: () => {'name': existingData['name'] ?? ''},
            )['name'] ?? existingData['name'] ?? '',
          'scores': existingData['scores'] ?? [], // Keep existing scores if any
          'hasTakenExam': false,
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
