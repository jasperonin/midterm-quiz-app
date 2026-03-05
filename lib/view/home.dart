// lib/home.dart
import 'package:app/screens/major_exam/major_exam_screen.dart';
import 'package:flutter/material.dart';
import '../models/exam_type.dart';
import '../screens/quiz_screen.dart';
import '../widgets/exam_selection/exam_selection_modal.dart';
import '../widgets/login/login_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

                // Welcome text
                const Text(
                  'Welcome!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  'by Leo',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 50),

                // Main Login Button
                ElevatedButton(
                  onPressed: () => _showLoginModal(context),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // In home.dart, update the _showLoginModal method:

  void _showLoginModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: const LoginModal(),
        );
      },
    ).then((result) {
      // DEBUG: Print the actual result
      print('🔍 RAW RESULT: $result');
      print('🔍 RESULT TYPE: ${result.runtimeType}');

      if (result != null) {
        print('🔍 RESULT KEYS: ${result is Map ? result.keys : 'Not a map'}');
      }

      // Handle login result
      if (result != null && result is Map) {
        String studentId = result['studentId']!;
        String lastName = result['lastName']!;

        print(
          '✅ Login successful, showing exam selection for: $studentId - $lastName',
        );
        _showExamSelectionDialog(studentId, lastName);
      } else {
        print('📝 Login cancelled or no result');
      }
    });
  }

  // Show exam selection modal
  // In home.dart, make sure you have this method
  void _showExamSelectionDialog(String studentId, String studentName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          ExamSelectionModal(studentId: studentId, studentName: studentName),
    ).then((selectedType) {
      if (selectedType != null) {
        if (selectedType == ExamType.regularQuiz) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                studentId: studentId == 'GUEST' ? null : studentId,
                studentName: studentName,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MajorExamScreen(
                studentId: studentId,
                studentName: studentName,
              ),
            ),
          );
        }
      }
    });
  }
}
