// lib/widgets/login/login_modal.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginModal extends StatefulWidget {
  const LoginModal({super.key});

  @override
  _LoginModalState createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool _isLoading = false;
  bool _isIdValidated = false;
  String? _errorMessage;
  String? _validatedStudentId;

  @override
  void initState() {
    super.initState();
    print('📱 [LoginModal] initialized');
  }

  @override
  void dispose() {
    print('🧹 [LoginModal] disposing');
    _studentIdController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  // Validate Student ID against Firestore
  Future<void> _validateStudentId() async {
    String studentId = _studentIdController.text.trim();
    print('📝 [LoginModal] Validating student ID: "$studentId"');

    if (studentId.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter Student ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if student ID exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .get();

      if (userDoc.exists) {
        print('✅ [LoginModal] Student ID found: $studentId');
        setState(() {
          _isIdValidated = true;
          _validatedStudentId = studentId;
          _isLoading = false;
        });
      } else {
        print('❌ [LoginModal] Student ID not found: $studentId');
        setState(() {
          _errorMessage = 'Student ID not found in database';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [LoginModal] Firestore error: $e');
      setState(() {
        _errorMessage = 'Error validating ID. Please try again.';
        _isLoading = false;
      });
    }
  }

  // Validate Last Name against Firestore
  Future<void> _validateLastName() async {
    String lastName = _lastNameController.text.trim();
    print(
      '📝 [LoginModal] Validating last name: "$lastName" for ID: $_validatedStudentId',
    );

    // Check for empty field first
    if (lastName.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter Last Name';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check Firestore for the student record
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_validatedStudentId)
          .get();

      if (userDoc.exists) {
        // Get the stored last name from Firestore
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String storedLastName = userData['name'] ?? '';

        print('📄 [LoginModal] Stored last name: "$storedLastName"');

        // Case-insensitive comparison
        bool isValid = storedLastName.toLowerCase() == lastName.toLowerCase();

        if (isValid) {
          print(
            '✅ [LoginModal] Login successful for: $_validatedStudentId - $lastName',
          );

          // Success - return credentials
          // In _validateLastName method, when successful:
          Navigator.pop(context, {
            'studentId': _validatedStudentId,
            'lastName': lastName, // Make sure this key matches exactly
          });
        } else {
          setState(() {
            _errorMessage = 'Last name does not match our records';
            _isLoading = false;
          });
        }
      } else {
        // Student ID not found in database (shouldn't happen since we validated earlier)
        setState(() {
          _errorMessage = 'Student record not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [LoginModal] Firestore error: $e');
      setState(() {
        _errorMessage = 'Error validating. Please try again.';
        _isLoading = false;
      });
    }
  }

  // Reset to start over
  void _resetLogin() {
    print('🔄 [LoginModal] Resetting login');
    setState(() {
      _isIdValidated = false;
      _validatedStudentId = null;
      _lastNameController.clear();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button if needed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_isIdValidated)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _resetLogin,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                const SizedBox(width: 40),

              Text(
                _isIdValidated ? 'Verify Last Name' : 'Student Login',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),

              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  print('❌ [LoginModal] Closed by user');
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            _isIdValidated
                ? 'Please enter your last name to continue'
                : 'Enter your Student ID to access the quiz',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),

          const SizedBox(height: 24),

          // Error message if any
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Step 1: Student ID Field
          if (!_isIdValidated) ...[
            TextField(
              controller: _studentIdController,
              decoration: InputDecoration(
                labelText: 'Student ID',
                hintText: 'e.g., 12346',
                prefixIcon: const Icon(Icons.badge, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
              autofocus: true,
              onSubmitted: (_) => _validateStudentId(),
            ),

            const SizedBox(height: 16),

            // Validate ID Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _validateStudentId,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],

          // Step 2: Last Name Field
          if (_isIdValidated) ...[
            // Show validated ID
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ID: $_validatedStudentId',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                hintText: 'e.g., Albit',
                prefixIcon: const Icon(Icons.person, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              enabled: !_isLoading,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _validateLastName(),
            ),

            const SizedBox(height: 16),

            // Validate Last Name Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _validateLastName,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Login', style: TextStyle(fontSize: 16)),
              ),
            ),

            // Error footer with retry option
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _resetLogin,
                      child: const Text('Try Different ID'),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
