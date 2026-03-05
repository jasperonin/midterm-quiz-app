// Run this script once to add tabSwitchCount to all users
// lib/scripts/add_tab_counter_to_users.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';

class AddTabCounterToUsers {
  static Future<void> addCounterToAllUsers() async {
    print('🚀 Adding tabSwitchCount to all users...');

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      print('📊 Found ${usersSnapshot.docs.length} users');

      int updated = 0;
      for (var userDoc in usersSnapshot.docs) {
        await userDoc.reference.update({
          'tabSwitchCount': 0, // Initialize to 0
          'lastTabReset': FieldValue.serverTimestamp(),
        });
        updated++;
        print('✅ Added counter to: ${userDoc.id}');
      }

      print('═══════════════════════════════════════════');
      print('✅ COMPLETE! Added counter to $updated users');
    } catch (e) {
      print('❌ Error: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AddTabCounterToUsers.addCounterToAllUsers();
}
