// lib/scripts/migrate_student_details_fields.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('🚀 Starting student details fields migration...');
  print('═══════════════════════════════════════════');
  
  try {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();
    
    print('📊 Found ${usersSnapshot.docs.length} users');
    
    int successCount = 0;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    int operationCount = 0;
    
    for (var userDoc in usersSnapshot.docs) {
      try {
        final data = userDoc.data();
        
        // Check if fields already exist
        bool hasGradedOral = data.containsKey('gradedOral');
        bool hasHandsOn = data.containsKey('handsOnActivities');
        bool hasProject = data.containsKey('project');
        bool hasExam = data.containsKey('exam');
        
        // Prepare migration data (only add if missing)
        Map<String, dynamic> updateData = {};
        
        if (!hasGradedOral) {
          updateData['gradedOral'] = {
            'score': null,
            'maxScore': 100,
            'remarks': '',
            'date': null,
            'lastUpdated': FieldValue.serverTimestamp(),
          };
        }
        
        if (!hasHandsOn) {
          updateData['handsOnActivities'] = [];
        }
        
        if (!hasProject) {
          updateData['project'] = {
            'title': '',
            'score': null,
            'maxScore': 100,
            'feedback': '',
            'date': null,
            'lastUpdated': FieldValue.serverTimestamp(),
          };
        }
        
        if (!hasExam) {
          updateData['exam'] = {
            'written': null,
            'writtenMax': 100,
            'coding': null,
            'codingMax': 100,
            'date': null,
          };
        }
        
        if (!data.containsKey('finalGrade')) {
          updateData['finalGrade'] = {
            'total': 0,
            'percentage': 0,
            'grade': 0,
            'status': 'pending'
          };
        }
        
        if (updateData.isNotEmpty) {
          batch.update(userDoc.reference, updateData);
          operationCount++;
          successCount++;
          print('📝 Added fields for: ${userDoc.id}');
        } else {
          print('⏭️ Already migrated: ${userDoc.id}');
        }
        
        if (operationCount >= 400) {
          await batch.commit();
          print('✅ Committed batch');
          batch = FirebaseFirestore.instance.batch();
          operationCount = 0;
        }
        
      } catch (e) {
        print('❌ Failed for ${userDoc.id}: $e');
      }
    }
    
    if (operationCount > 0) {
      await batch.commit();
      print('✅ Committed final batch');
    }
    
    print('═══════════════════════════════════════════');
    print('✅ MIGRATION COMPLETE!');
    print('📊 Updated: $successCount users');
    print('📋 New fields added:');
    print('   • gradedOral');
    print('   • handsOnActivities');
    print('   • project');
    print('   • exam');
    print('   • finalGrade');
    print('═══════════════════════════════════════════');
    
  } catch (e) {
    print('❌ FATAL ERROR: $e');
  }
}