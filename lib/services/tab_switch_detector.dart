// lib/services/tab_switch_detector.dart - Fixed version
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

@JS()
external JSObject get document;

@JS()
external JSObject get window;

@JS()
extension DocumentExtension on JSObject {
  @JS('visibilityState')
  external String get visibilityState;
  
  @JS('addEventListener')
  external void documentAddEventListener(String type, JSFunction listener);
  
  @JS('removeEventListener')
  external void documentRemoveEventListener(String type, JSFunction listener);
}

@JS()
extension WindowExtension on JSObject {
  @JS('addEventListener')
  external void addEventListener(String type, JSFunction listener);
  
  @JS('removeEventListener')
  external void windowRemoveEventListener(String type, JSFunction listener);
}

class TabSwitchDetector {
  static const String _violationCountKey = 'tab_switch_violations';
  static const int _maxViolations = 2;
  
  final Function(int)? onViolation;  // Pass current count
  final VoidCallback? onMaxViolationsReached;
  
  int _violationCount = 0;
  bool _isMonitoring = false;
  bool _quizActive = false;
  JSFunction? _visibilityHandler;
  JSFunction? _blurHandler;
  SharedPreferences? _prefs;
  
  TabSwitchDetector({
    this.onViolation,
    this.onMaxViolationsReached,
  });
  
  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      print('✅ SharedPreferences ready');
    } catch (e) {
      print('⚠️ SharedPreferences not available: $e');
    }
  }
  
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    
    await _initPrefs();
    
    _isMonitoring = true;
    _quizActive = true;
    
    await _loadViolationCount();
    
    print('🔍 Tab switch monitoring started');
    print('📊 Current violations: $_violationCount');
    
    // Create handlers as Dart functions with proper binding
    _visibilityHandler = _handleVisibilityChange.toJS;
    _blurHandler = _handleWindowBlur.toJS;
    
    // Add listeners
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
      print('🚫 Tab switch detected - user left tab');
      _handleTabSwitch();
    } else if (visibilityState == 'visible') {
      print('👋 User returned to tab');
    }
  }
  
  void _handleWindowBlur() {
    print('🪟 Window blur triggered');
    if (!_quizActive) return;
    
    print('🪟 Window lost focus');
    _handleTabSwitch();
  }
  
  Future<void> _handleTabSwitch() async {
    if (!_quizActive) return;
    
    _violationCount++;
    await _saveViolationCount();
    
    print('⚠️ VIOLATION #$_violationCount (Max: $_maxViolations)');
    
    // Trigger violation callback with current count
    if (onViolation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onViolation!(_violationCount);
      });
    }
    
    // Check if max violations reached
    if (_violationCount >= _maxViolations) {
      print('❌ MAX VIOLATIONS REACHED - Terminating quiz');
      _quizActive = false;
      
      if (onMaxViolationsReached != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onMaxViolationsReached!();
        });
      }
    }
  }
  
  Future<void> _loadViolationCount() async {
    if (_prefs != null) {
      _violationCount = _prefs!.getInt(_violationCountKey) ?? 0;
    } else {
      _violationCount = 0;
    }
  }
  
  Future<void> _saveViolationCount() async {
    try {
      if (_prefs != null) {
        await _prefs!.setInt(_violationCountKey, _violationCount);
        print('💾 Saved violation count: $_violationCount');
      }
    } catch (e) {
      print('⚠️ Failed to save violation count: $e');
    }
  }
  
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    print('🛑 Stopping monitoring');
    
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
    
    try {
      if (_prefs != null) {
        await _prefs!.remove(_violationCountKey);
      }
    } catch (e) {
      print('⚠️ Failed to reset violations: $e');
    }
    
    print('🔄 Violations reset');
  }
  
  int get violationCount => _violationCount;
  bool get isMonitoring => _isMonitoring;
}