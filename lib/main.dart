// lib/main.dart
import 'package:app/view/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  // MUST be first
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized successfully');
    } else {
      debugPrint('✅ Firebase already initialized');
    }
  } catch (e) {
    debugPrint('❌ Firebase init error: $e');
    // Continue running - app might work in offline mode
  }

  // Initialize shared_preferences
  try {
    await SharedPreferences.getInstance();
    debugPrint('✅ SharedPreferences initialized');
  } catch (e) {
    debugPrint('⚠️ SharedPreferences not available: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if we're on web platform
    const bool isWeb = identical(0, 0.0);

    if (isWeb) {
      return FlutterWebFrame(
        builder: (context) {
          return MaterialApp(
            title: 'Quiz App',
            theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
        maximumSize: const Size(400, 830),
        backgroundColor: Colors.grey.shade300,
        enabled: true,
      );
    } else {
      return MaterialApp(
        title: 'Quiz App',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      );
    }
  }
}
