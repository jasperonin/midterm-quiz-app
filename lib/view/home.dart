// lib/home.dart - Complete working version
import 'package:flutter/material.dart';
import '../screens/quiz_screen.dart';
import '../widgets/login_dialog.dart';

class HomeScreen extends StatefulWidget {
  // Changed to StatefulWidget
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _studentIdController = TextEditingController();

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.quiz,
                    size: 80,
                    color: Colors.blue.shade800,
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Midterm Exam',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  'by Leo',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 50),

                // Login Button
                ElevatedButton(
                  onPressed: () => _showLoginDialog(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Click to Login', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Guest mode (working)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    print('📱 [HomeScreen] Showing login dialog');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const LoginDialog();
      },
    ).then((result) {
      // Handle the result when dialog closes
      print('📱 [HomeScreen] Dialog closed with result: $result');

      if (result != null && result is Map<String, dynamic>) {
        String studentId = result['studentId'] ?? '';
        String lastName = result['lastName'] ?? '';

        print('✅ [HomeScreen] Login successful for: $studentId - $lastName');

        // Navigate to quiz screen with student data
        // After successful login
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              studentId: studentId,
              studentName: lastName,
              // quizId: 'specific-quiz-id', // Optional: load specific quiz
            ),
          ),
        );
      } else {
        print('📱 [HomeScreen] Dialog closed without login');
      }
    });
  }
}
