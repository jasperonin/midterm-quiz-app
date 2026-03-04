// lib/widgets/login_dialog.dart - Add better error handling
import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final AuthService _authService = AuthService();

  // Controllers
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _isIdValidated = false;
  String? _errorMessage;
  String? _validatedStudentId;

  @override
  void initState() {
    super.initState();
    print('📱 [LoginDialog] initialized');
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  // Step 1: Validate Student ID
  Future<void> _validateStudentId() async {
    String studentId = _studentIdController.text.trim();
    print('📝 [LoginDialog] Validating student ID: "$studentId"');

    if (studentId.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your Student ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool exists = await _authService.validateStudentId(studentId);
      print('📝 [LoginDialog] Validation result: $exists');

      if (exists) {
        setState(() {
          _isIdValidated = true;
          _validatedStudentId = studentId;
          _isLoading = false;
        });
        print('✅ [LoginDialog] ID validated, moving to step 2');
      } else {
        setState(() {
          _errorMessage = 'Unable to find ID: $studentId in the database';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [LoginDialog] Unexpected error: $e');
      setState(() {
        _errorMessage = 'Error validating ID. Please try again.';
        _isLoading = false;
      });
    }
  }

  // Step 2: Validate Last Name
  Future<void> _validateLastName() async {
    String lastName = _lastNameController.text.trim();
    print(
      '📝 [LoginDialog] Validating last name: "$lastName" for ID: $_validatedStudentId',
    );

    if (lastName.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your last name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> result = await _authService.validateLastName(
        _validatedStudentId!,
        lastName,
      );

      print('📝 [LoginDialog] Validation result: $result');
      bool isValid = result['success'] ?? false;

      if (isValid) {
        print('✅ [LoginDialog] Login successful for: $_validatedStudentId');

        if (mounted) {
          Navigator.pop(context, {
            'studentId': _validatedStudentId,
            'lastName': lastName,
            'userData': result['userData'],
          });
        }
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Last name does not match';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [LoginDialog] Unexpected error: $e');
      setState(() {
        _errorMessage = 'Error validating last name. Please try again.';
        _isLoading = false;
      });
    }
  }

  // Reset to start over
  void _resetLogin() {
    print('🔄 [LoginDialog] Resetting login');
    setState(() {
      _isIdValidated = false;
      _validatedStudentId = null;
      _lastNameController.clear();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
      '🎨 [LoginDialog] Building with state: isIdValidated=$_isIdValidated, isLoading=$_isLoading',
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
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
                    print('❌ [LoginDialog] Closed by user');
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
                  : 'Enter your Student ID',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 24),

            // Show error message if any
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
                  labelText: 'Enter Student ID',
                  hintText: 'e.g, 123456',
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

              const SizedBox(height: 24),

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

              const SizedBox(height: 24),

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
                      : const Text(
                          'Start Quiz',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Guest mode link (for testing)
            // if (!_isIdValidated)
            //   Center(
            //     child: TextButton(
            //       onPressed: () {
            //         print('👤 [LoginDialog] Guest mode selected');
            //         Navigator.pop(context);
            //         // Navigate to quiz as guest
            //         Navigator.pushNamed(context, '/quiz');
            //       },
            //       child: Text(
            //         'Continue as Guest (Testing Only)',
            //         style: TextStyle(color: Colors.grey.shade600),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
