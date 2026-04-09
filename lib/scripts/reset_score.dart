// lib/scripts/simple_reset.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await resetExamStatus();
}

Future<void> resetExamStatus() async {
  try {
    print('🚀 Starting exam status reset...');

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    print('✅ Firebase initialized');
    print('🔄 Resetting exam status...');

    final firestore = FirebaseFirestore.instance;
    final usersRef = firestore.collection('users');

    // Get all users
    final snapshot = await usersRef.get();
    print('📊 Found ${snapshot.docs.length} users');

    int successCount = 0;
    int errorCount = 0;

    for (var doc in snapshot.docs) {
      try {
        await doc.reference.update({
          'examStatus': 'inactive',
          'hasTakenExam': false,
          'tabSwitchCount': 0,
          'lastReset': FieldValue.serverTimestamp(),
        });
        print('✅ Reset user: ${doc.id}');
        successCount++;
      } catch (e) {
        print('❌ Failed to reset user ${doc.id}: $e');
        errorCount++;
      }
    }

    print('');
    print('🎯 Reset Complete!');
    print('✅ Successful: $successCount');
    print('❌ Failed: $errorCount');
    print('✅ All users reset successfully!');
  } catch (e) {
    print('❌ Fatal Error: $e');
  } finally {
    print('👋 Exiting...');
  }
}
