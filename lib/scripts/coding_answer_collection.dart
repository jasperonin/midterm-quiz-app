// lib/scripts/create_coding_answers_collection.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../firebase_options.dart';

class CreateCodingAnswersCollection {
  static Future<void> migrate() async {
    print('🚀 Creating codingExamAnswerByStudent collection...');
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
      final codingAnswersRef = FirebaseFirestore.instance
          .collection('codingExamAnswerByStudent');
      
      // For each student, create an empty answer document
      for (var userDoc in usersSnapshot.docs) {
        final studentId = userDoc.id;
        final studentData = userDoc.data();
        final studentName = studentData['last_name'] ?? studentData['name'] ?? 'Unknown';
        
        // Check if document already exists
        final existingDoc = await codingAnswersRef.doc(studentId).get();
        
        if (!existingDoc.exists) {
          // Create empty answer document
          await codingAnswersRef.doc(studentId).set({
            'studentId': studentId,
            'studentName': studentName,
            'answers': [], // Will be populated when student submits
            'submittedAt': null,
            'status': 'pending', // pending, submitted, graded
            'totalScore': 0
          });
          
          createdCount++;
          print('📝 Created answer document for: $studentId - $studentName');
        } else {
          skippedCount++;
          print('⏭️ Answer document already exists for: $studentId');
        }
      }
      
      print('═══════════════════════════════════════════');
      print('✅ COLLECTION SETUP COMPLETE!');
      print('📌 Collection: codingExamAnswerByStudent');
      print('📊 Documents created: $createdCount');
      print('📊 Documents skipped (already exist): $skippedCount');
      print('═══════════════════════════════════════════');
      
      // Show sample structure
      if (createdCount > 0) {
        print('\n📋 Sample document structure:');
        print('''
{
  "studentId": "5250525",
  "studentName": "Tan",
  "answers": [
    {
      "questionId": 1,
      "difficulty": "easy",
      "code": "// Student's code here",
      "submittedAt": Timestamp,
      "score": null,  // To be filled by teacher
      "feedback": null // To be filled by teacher
    }
  ],
  "submittedAt": null,
  "status": "pending",
  "totalScore": 0,
  "createdAt": Timestamp,
  "lastUpdated": Timestamp
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
  print('🔄 Starting coding answers collection creation...');
  print('⚠️  This will create empty answer documents for all students');
  print('⏳ This may take a few minutes...\n');
  
  WidgetsFlutterBinding.ensureInitialized();
  await CreateCodingAnswersCollection.migrate();
}