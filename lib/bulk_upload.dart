// save as import_users.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // Your generated Firebase options

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Your data as a list of maps
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

  print('Starting bulk import of ${users.length} users...');

  // Use a WriteBatch for atomic operations [citation:2]
  WriteBatch batch = FirebaseFirestore.instance.batch();

  // Add each user to the batch
  for (var user in users) {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user['id'] as String); // Use the ID as document ID

    batch.set(docRef, {
      'name': user['name'],
      'imported_at': FieldValue.serverTimestamp(),
    });
  }

  // Commit the batch (max 500 operations per batch) [citation:1]
  try {
    await batch.commit();
    print('✅ Successfully imported ${users.length} users!');
  } catch (e) {
    print('❌ Error importing users: $e');
  }
}
