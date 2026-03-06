// lib/teacher_main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import '../../firebase_options.dart';
import './teacher_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    print('✅ Firebase initialized for Teacher Dashboard');
  } catch (e) {
    print('❌ Firebase init error: $e');
  }

  runApp(const TeacherApp());
}

class TeacherApp extends StatelessWidget {
  const TeacherApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bool isWeb = identical(0, 0.0);

    if (isWeb) {
      return FlutterWebFrame(
        builder: (context) {
          return MaterialApp(
            title: 'Teacher Dashboard',
            theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
            home: const TeacherDashboard(),
            debugShowCheckedModeBanner: false,
          );
        },
        maximumSize: const Size(400, 830),
        backgroundColor: Colors.grey.shade300,
        enabled: true,
      );
    } else {
      return MaterialApp(
        title: 'Teacher Dashboard',
        theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
        home: const TeacherDashboard(),
        debugShowCheckedModeBanner: false,
      );
    }
  }
}
