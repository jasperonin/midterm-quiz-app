// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Step 1: Validate if student ID exists
  Future<bool> validateStudentId(String studentId) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(studentId)
          .get();

      bool exists = docSnapshot.exists;

      return exists;
    } catch (e) {
      return false;
    }
  }

  // Step 2: Validate last name matches student ID
  Future<Map<String, dynamic>> validateLastName(
    String studentId,
    String lastName,
  ) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(studentId)
          .get();

      if (docSnapshot.exists) {
        // Get the stored last name
        Map<String, dynamic> userData = docSnapshot.data() ?? {};
        String storedLastName = userData['name'] ?? '';

        // Case-insensitive comparison
        bool isValid =
            storedLastName.toLowerCase().trim() ==
            lastName.toLowerCase().trim();

        print(
          isValid
              ? '✅ [AuthService] Last name matches'
              : '❌ [AuthService] Last name does not match',
        );

        return {
          'success': isValid,
          'userData': userData,
          'error': isValid ? null : 'Last name does not match',
        };
      } else {
        return {
          'success': false,
          'userData': null,
          'error': 'Student ID not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'userData': null,
        'error': 'Error validating last name. Please try again.',
      };
    }
  }
}
