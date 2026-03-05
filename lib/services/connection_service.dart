// lib/services/connection_service.dart
import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart' show kIsWeb;

@JS('navigator')
external JSObject get _navigator;

@JS()
extension NavigatorExtension on JSObject {
  @JS('onLine')
  external bool get onLine;
}

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  bool _hasInternet = true;
  bool _isInitialized = false;

  // Simple stream that just polls every 30 seconds
  Stream<bool> get connectionStream => Stream<bool>.periodic(
    const Duration(seconds: 30),
    (_) => hasInternetConnectionSync(),
  ).distinct();

  // Synchronous check for web (fast, no async)
  bool hasInternetConnectionSync() {
    if (kIsWeb) {
      try {
        return _navigator.onLine;
      } catch (e) {
        return true;
      }
    }
    return true;
  }

  // Async check (same as sync for web, but kept for compatibility)
  Future<bool> hasInternetConnection() async {
    return hasInternetConnectionSync();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    _hasInternet = hasInternetConnectionSync();
    _isInitialized = true;

    print(
      kIsWeb
          ? '🌐 Web connection service initialized (simple mode)'
          : '📱 Non-web connection service initialized',
    );
  }

  bool get isConnected => _hasInternet;
}
