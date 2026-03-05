// lib/main.dart with loading screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './view/home.dart';
import 'firebase_env_options.dart';
import './utils/platform_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();

    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY']!,
        appId: dotenv.env['FIREBASE_APP_ID']!,
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
        projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      ),
    );

    // 👇 ENABLE OFFLINE PERSISTENCE
    // Configure Firestore settings for persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );

    print('✅ Firebase offline persistence enabled');
  } catch (e) {
    print('❌ Firebase init error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(options: FirebaseEnvOptions.currentPlatform);
      print('✅ Firebase initialized');

      // Initialize SharedPreferences
      await SharedPreferences.getInstance();
      print('✅ SharedPreferences initialized');

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('❌ Initialization failed: $e');
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're on web
    const bool isWeb = identical(0, 0.0);

    if (!_isInitialized) {
      // Show loading screen while initializing
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  _error ?? 'Initializing app...',
                  style: TextStyle(
                    color: _error != null ? Colors.red : Colors.grey,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _isInitialized = false;
                      });
                      _initializeServices();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // App is initialized, show main content
    if (PlatformUtils.isWeb) {
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
