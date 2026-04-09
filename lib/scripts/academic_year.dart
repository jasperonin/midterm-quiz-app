// lib/scripts/migrate_academic_calendar.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('🚀 Creating academic calendar settings...');
  print('═══════════════════════════════════════════');
  
  try {
    final settingsRef = FirebaseFirestore.instance
        .collection('settings')
        .doc('academicCalendar');
    
    // Check if already exists
    final existingDoc = await settingsRef.get();
    
    if (!existingDoc.exists) {
      // Default date ranges for 2024
      final defaultSettings = {
        'currentYear': 2024,
        'terms': {
          'midterm': {
            'name': 'Midterm',
            'startDate': Timestamp.fromDate(DateTime(2026, 2, 1)),
            'endDate': Timestamp.fromDate(DateTime(2026, 4, 30)),
            'isActive': true,
          },
          'finals': {
            'name': 'Finals',
            'startDate': Timestamp.fromDate(DateTime(2026, 5, 1)),
            'endDate': Timestamp.fromDate(DateTime(2026, 7, 31)),
            'isActive': true,
          }
        },
        'autoAssign': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'updatedBy': 'system',
      };
      
      await settingsRef.set(defaultSettings);
      print('✅ Academic calendar created with default dates:');
      print('   Midterm: Feb 1, 2024 - Apr 30, 2024');
      print('   Finals: May 1, 2024 - Jul 31, 2024');
    } else {
      print('⏭️ Academic calendar already exists, skipping...');
      print('📋 Current settings:');
      final data = existingDoc.data();
      print('   Midterm: ${data?['terms']['midterm']['startDate']}');
      print('   Finals: ${data?['terms']['finals']['startDate']}');
    }
    
    print('═══════════════════════════════════════════');
    print('✅ MIGRATION COMPLETE!');
    
  } catch (e) {
    print('❌ ERROR: $e');
  }
}