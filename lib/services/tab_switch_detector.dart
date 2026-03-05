// lib/services/tab_switch_detector.dart
import 'dart:js_interop';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@JS()
external JSObject get document;

@JS()
external JSObject get window;

@JS()
extension DocumentExtension on JSObject {
  @JS('visibilityState')
  external String get visibilityState;
  
  @JS('addEventListener')
  external void addEventListener(String type, JSFunction listener);
  
  @JS('removeEventListener')
  external void documentRemoveEventListener(String type, JSFunction listener);
}

@JS()
extension WindowExtension on JSObject {
  @JS('addEventListener')
  external void documentAddEventListener(String type, JSFunction listener);
  
  @JS('removeEventListener')
  external void windowRemoveEventListener(String type, JSFunction listener);
}

class TabSwitchDetector {
  static const int _maxViolations = 2;
  
  final String? studentId; // 👈 Add studentId
  final Function(int)? onViolation;
  final VoidCallback? onMaxViolationsReached;
  
  int _violationCount = 0;
  bool _isMonitoring = false;
  bool _quizActive = false;
  JSFunction? _visibilityHandler;
  JSFunction? _blurHandler;
  
  // Debounce mechanism
  Timer? _debounceTimer;
  bool _lastWasVisibilityChange = false;
  static const int _debounceDuration = 1000;
  
  TabSwitchDetector({
    required this.studentId, // 👈 Make required
    this.onViolation,
    this.onMaxViolationsReached,
  });
  
  // 👇 NEW: Load count from Firestore
  Future<void> _loadViolationCount() async {
    if (studentId == null) return;
    
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .get();
      
      if (userDoc.exists) {
        _violationCount = userDoc.data()?['tabSwitchCount'] ?? 0;
        print('📊 Loaded tabSwitchCount from Firestore: $_violationCount for $studentId');
      }
    } catch (e) {
      print('❌ Error loading tabSwitchCount: $e');
      _violationCount = 0;
    }
  }
  
  // 👇 NEW: Save count to Firestore
  Future<void> _saveViolationCount() async {
    if (studentId == null) return;
    
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .update({
        'tabSwitchCount': _violationCount,
        'lastTabSwitch': FieldValue.serverTimestamp(),
      });
      print('💾 Saved tabSwitchCount to Firestore: $_violationCount for $studentId');
    } catch (e) {
      print('❌ Error saving tabSwitchCount: $e');
    }
  }
  
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _quizActive = true;
    
    // Load from Firestore instead of SharedPreferences
    await _loadViolationCount();
    
    print('🔍 Tab switch monitoring started for student: $studentId');
    print('📊 Current violations: $_violationCount');
    
    _visibilityHandler = _handleVisibilityChange.toJS;
    _blurHandler = _handleWindowBlur.toJS;
    
    document.addEventListener('visibilitychange', _visibilityHandler!);
    window.addEventListener('blur', _blurHandler!);
    
    print('✅ Event listeners attached');
  }
  
  void _handleVisibilityChange() {
    print('👁️ Visibility change triggered');
    
    if (!_quizActive) {
      print('⏸️ Quiz not active, ignoring');
      return;
    }
    
    final visibilityState = document.visibilityState;
    print('👁️ Visibility state: $visibilityState');
    
    if (visibilityState == 'hidden') {
      print('🚫 User left tab');
      _lastWasVisibilityChange = true;
      _debouncedHandleTabSwitch();
    } else if (visibilityState == 'visible') {
      print('👋 User returned to tab');
    }
  }
  
  void _handleWindowBlur() {
    print('🪟 Window blur triggered');
    
    if (!_quizActive) return;
    
    if (!_lastWasVisibilityChange) {
      print('🪟 Window lost focus (separate from tab switch)');
      _debouncedHandleTabSwitch();
    } else {
      print('🪟 Window blur ignored (already counted via visibility)');
    }
    
    _lastWasVisibilityChange = false;
  }
  
  void _debouncedHandleTabSwitch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: _debounceDuration), () {
      _handleTabSwitch();
    });
  }
  
  Future<void> _handleTabSwitch() async {
    if (!_quizActive) return;
    
    _violationCount++;
    
    // 👇 Save to Firestore immediately
    await _saveViolationCount();
    
    print('⚠️ VIOLATION #$_violationCount for student $studentId');
    
    // Trigger violation callback with current count
    if (onViolation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onViolation!(_violationCount);
      });
    }
    
    // Check if max violations reached
    if (_violationCount >= _maxViolations) {
      print('❌ MAX VIOLATIONS REACHED for student $studentId');
      _quizActive = false;
      
      if (onMaxViolationsReached != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onMaxViolationsReached!();
        });
      }
    }
  }
  
  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;
    
    print('🛑 Stopping monitoring for student $studentId');
    
    _debounceTimer?.cancel();
    
    if (_visibilityHandler != null) {
      document.documentRemoveEventListener('visibilitychange', _visibilityHandler!);
    }
    
    if (_blurHandler != null) {
      window.windowRemoveEventListener('blur', _blurHandler!);
    }
    
    _isMonitoring = false;
    _quizActive = false;
  }
  
  Future<void> resetViolations() async {
    _violationCount = 0;
    _debounceTimer?.cancel();
    
    // 👇 Reset in Firestore
    await _saveViolationCount();
    
    print('🔄 Violations reset for student $studentId');
  }
  
  int get violationCount => _violationCount;
  bool get isMonitoring => _isMonitoring;
}