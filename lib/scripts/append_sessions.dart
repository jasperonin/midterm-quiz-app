// lib/scripts/add_session_fields.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('🚀 Starting session fields migration...');
  print('═══════════════════════════════════════════');
  
  try {
    // Get all users
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();
    
    print('📊 Found ${usersSnapshot.docs.length} users to update');
    
    int successCount = 0;
    int failCount = 0;
    
    // Use batch for efficient updates
    WriteBatch batch = FirebaseFirestore.instance.batch();
    int operationCount = 0;
    
    for (var userDoc in usersSnapshot.docs) {
      try {
        // Prepare session fields
        Map<String, dynamic> updateData = {
          'activeSessions': {}, // Empty map for now
          'maxSessions': 1,      // Default to 1 device at a time
          'sessionSettings': {
            'allowMultipleDevices': false,
            'enforceStrict': true,
            'timeoutMinutes': 30,
            'lastUpdated': FieldValue.serverTimestamp(),
          }
        };
        
        // Add to batch
        batch.update(userDoc.reference, updateData);
        operationCount++;
        successCount++;
        
        if (operationCount >= 400) {
          await batch.commit();
          print('✅ Committed batch of $operationCount updates');
          batch = FirebaseFirestore.instance.batch();
          operationCount = 0;
        }
        
      } catch (e) {
        print('❌ Failed to update user ${userDoc.id}: $e');
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
    print('📊 Successful: $successCount users');
    if (failCount > 0) print('❌ Failed: $failCount users');
    print('📋 Fields added:');
    print('   • activeSessions: {} (empty map)');
    print('   • maxSessions: 1 (default)');
    print('   • sessionSettings: {allowMultipleDevices: false, timeoutMinutes: 30}');
    print('═══════════════════════════════════════════');
    
  } catch (e) {
    print('❌ FATAL ERROR: $e');
  }
}