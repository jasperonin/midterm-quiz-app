// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Step 1: Validate if student ID exists
  Future<bool> validateStudentId(String studentId) async {
    try {
      print('🔍 [AuthService] Checking if student ID exists: $studentId');
      
      final docSnapshot = await _firestore
          .collection('users')
          .doc(studentId)
          .get();
      
      bool exists = docSnapshot.exists;
      
      if (exists) {
        print('✅ [AuthService] Student ID found: $studentId');
        // Print the data for debugging
        print('📄 [AuthService] User data: ${docSnapshot.data()}');
      } else {
        print('❌ [AuthService] Student ID not found: $studentId');
      }
      
      return exists;
    } catch (e) {
      print('❌ [AuthService] Error validating student ID: $e');
      print('❌ [AuthService] Error type: ${e.runtimeType}');
      return false;
    }
  }
  
  // Step 2: Validate last name matches student ID
  Future<Map<String, dynamic>> validateLastName(String studentId, String lastName) async {
    try {
      print('🔍 [AuthService] Validating last name for student: $studentId');
      print('🔍 [AuthService] Provided last name: "$lastName"');
      
      final docSnapshot = await _firestore
          .collection('users')
          .doc(studentId)
          .get();
      
      if (docSnapshot.exists) {
        // Get the stored last name
        Map<String, dynamic> userData = docSnapshot.data() ?? {};
        String storedLastName = userData['name'] ?? '';
        
        print('📄 [AuthService] Stored last name: "$storedLastName"');
        print('📄 [AuthService] Full user data: $userData');
        
        // Case-insensitive comparison
        bool isValid = storedLastName.toLowerCase().trim() == 
                      lastName.toLowerCase().trim();
        
        print(isValid 
            ? '✅ [AuthService] Last name matches' 
            : '❌ [AuthService] Last name does not match');
        
        return {
          'success': isValid,
          'userData': userData,
          'error': isValid ? null : 'Last name does not match',
        };
      } else {
        print('❌ [AuthService] Student ID not found during last name validation');
        return {
          'success': false,
          'userData': null,
          'error': 'Student ID not found',
        };
      }
    } catch (e) {
      print('❌ [AuthService] Error validating last name: $e');
      print('❌ [AuthService] Error type: ${e.runtimeType}');
      return {
        'success': false,
        'userData': null,
        'error': 'Error validating last name. Please try again.',
      };
    }
  }
}