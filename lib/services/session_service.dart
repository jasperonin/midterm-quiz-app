import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // In session_service.dart, update the checkSessionLimit method:

  Future<SessionLimitCheck> checkSessionLimit(String userId) async {
    try {
      // Get user document
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        await _createUserWithDefaultSessions(userId);
        return SessionLimitCheck(
          allowed: true,
          message: 'New user created',
          currentSessions: 0,
          maxSessions: 1,
        );
      }

      final userData = userDoc.data() ?? {};

      // Handle maxSessions - ensure it's an int
      int maxSessions = 1; // default
      if (userData.containsKey('maxSessions')) {
        var value = userData['maxSessions'];
        if (value is int) {
          maxSessions = value;
        } else if (value is String) {
          maxSessions = int.tryParse(value) ?? 1;
        } else if (value is num) {
          maxSessions = value.toInt();
        }
      }

      // Handle activeSessions - ensure it's an int
      int activeSessions = 0; // default
      if (userData.containsKey('activeSessions')) {
        var value = userData['activeSessions'];
        if (value is int) {
          activeSessions = value;
        } else if (value is String) {
          activeSessions = int.tryParse(value) ?? 0;
        } else if (value is num) {
          activeSessions = value.toInt();
        }
      }

      debugPrint(
        '📊 Session check for user $userId: active=$activeSessions, max=$maxSessions',
      );

      if (activeSessions >= maxSessions) {
        return SessionLimitCheck(
          allowed: false,
          message:
              'You have reached the maximum limit of $maxSessions active sessions. Please complete or close other sessions.',
          currentSessions: activeSessions,
          maxSessions: maxSessions,
        );
      }

      return SessionLimitCheck(
        allowed: true,
        message: 'Session can be started',
        currentSessions: activeSessions,
        maxSessions: maxSessions,
      );
    } catch (e) {
      debugPrint('❌ Error checking session limit: $e');
      return SessionLimitCheck(
        allowed: true,
        message: 'Proceeding with session',
        currentSessions: 0,
        maxSessions: 1,
      );
    }
  }

  Future<void> _createUserWithDefaultSessions(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'student_id': userId,
        'maxSessions': 1,
        'activeSessions': 0,
        'examStatus': 'inactive',
        'hasTakenExam': false,
        'tabSwitchCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      });
      debugPrint(
        '✅ Created new user document for $userId with default session values',
      );
    } catch (e) {
      debugPrint('❌ Error creating user document: $e');
    }
  }

  Future<void> incrementActiveSessions(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'activeSessions': FieldValue.increment(1),
        'lastActive': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Incremented active sessions for $userId');
    } catch (e) {
      debugPrint('❌ Error incrementing active sessions: $e');
      // If update fails, try to set initial value
      try {
        await _firestore.collection('users').doc(userId).set({
          'activeSessions': 1,
          'lastActive': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('✅ Set initial active sessions for $userId');
      } catch (e2) {
        debugPrint('❌ Error setting initial active sessions: $e2');
      }
    }
  }

  Future<void> decrementActiveSessions(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'activeSessions': FieldValue.increment(-1),
        'lastActive': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Decremented active sessions for $userId');
    } catch (e) {
      debugPrint('❌ Error decrementing active sessions: $e');
    }
  }

  // Optional: Reset active sessions (useful for cleanup)
  Future<void> resetActiveSessions(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'activeSessions': 0,
        'lastActive': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Reset active sessions for $userId');
    } catch (e) {
      debugPrint('❌ Error resetting active sessions: $e');
    }
  }
}

class SessionLimitCheck {
  final bool allowed;
  final String message;
  final int currentSessions;
  final int maxSessions;

  SessionLimitCheck({
    required this.allowed,
    required this.message,
    required this.currentSessions,
    required this.maxSessions,
  });
}
