// lib/scripts/create_coding_answers_collection.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';

class CreateCodingAnswersCollection {
  static Future<void> migrate() async {
    print('🚀 Creating writtenExamAnswerByStudents collection...');
    print('═══════════════════════════════════════════');

    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized');

      // Get all students from users collection
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      print('📊 Found ${usersSnapshot.docs.length} students');

      int createdCount = 0;
      int skippedCount = 0;

      // Reference to the new collection
      final writtenAnswersRef = FirebaseFirestore.instance.collection(
        'writtenExamAnswerByStudents', // Fixed: consistent naming
      );

      // For each student, create an empty answer document
      for (var userDoc in usersSnapshot.docs) {
        final studentId = userDoc.id;
        final studentData = userDoc.data();
        final studentName =
            studentData['last_name'] ?? studentData['name'] ?? 'Unknown';

        // Check if document already exists
        final existingDoc = await writtenAnswersRef.doc(studentId).get();

        if (!existingDoc.exists) {
          // ✅ CORRECT: Only exam-related fields, NO session data
          await writtenAnswersRef.doc(studentId).set({
            'studentId': studentId,
            'studentName': studentName,
            'answers': [], // Will be populated when student submits
            'submittedAt': null,
            'status': 'pending', // pending, submitted, graded
            'totalScore': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          // ✅ ALSO update users collection with session fields
          await FirebaseFirestore.instance
              .collection('users')
              .doc(studentId)
              .set({
                'activeSessions': {}, // Empty map for device tracking
                'maxSessions': 1, // Allow 1 device at a time
                'sessionSettings': {
                  'allowMultipleDevices': false,
                  'enforceStrict': true,
                  'timeoutMinutes': 30,
                },
              }, SetOptions(merge: true));

          createdCount++;
          print('📝 Created answer document for: $studentId - $studentName');
        } else {
          skippedCount++;
          print('⏭️ Answer document already exists for: $studentId');
        }
      }

      print('═══════════════════════════════════════════');
      print('✅ COLLECTION SETUP COMPLETE!');
      print('📌 Collection: writtenExamAnswerByStudents');
      print('📊 Documents created: $createdCount');
      print('📊 Documents skipped (already exist): $skippedCount');
      print('═══════════════════════════════════════════');

      // Show sample structure
      if (createdCount > 0) {
        print('\n📋 Sample answer document structure:');
        print('''
writtenExamAnswerByStudents/5250525
{
  "studentId": "5250525",
  "studentName": "Tan",
  "answers": [
    {
      "questionId": 1,
      "selectedOption": "B",
      "isCorrect": true,
      "points": 2
    }
  ],
  "submittedAt": null,
  "status": "pending",
  "totalScore": 0,
  "createdAt": Timestamp,
  "lastUpdated": Timestamp
}

users/5250525 (updated with session fields)
{
  "activeSessions": {},
  "maxSessions": 1,
  "sessionSettings": {
    "allowMultipleDevices": false,
    "enforceStrict": true,
    "timeoutMinutes": 30
  }
}
        ''');
      }
    } catch (e) {
      print('❌ ERROR: $e');
      print('═══════════════════════════════════════════');
    }
  }
}

void main() async {
  print('🔄 Starting written exam answers collection creation...');
  print('⚠️  This will create empty answer documents for all students');
  print('⚠️  AND add session fields to users collection');
  print('⏳ This may take a few minutes...\n');

  WidgetsFlutterBinding.ensureInitialized();
  await CreateCodingAnswersCollection.migrate();
}
