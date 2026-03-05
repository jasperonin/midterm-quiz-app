import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseEnvOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'FirebaseEnvOptions is not configured for fuchsia.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _requireEnv('FIREBASE_API_KEY'),
    appId: _requireEnv('FIREBASE_APP_ID_WEB'),
    messagingSenderId: _requireEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _requireEnv('FIREBASE_PROJECT_ID'),
    authDomain: _envOrNull('FIREBASE_AUTH_DOMAIN'),
    storageBucket: _envOrNull('FIREBASE_STORAGE_BUCKET'),
    measurementId: _envOrNull('FIREBASE_MEASUREMENT_ID'),
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _requireEnv('FIREBASE_API_KEY'),
    appId: _requireEnv('FIREBASE_APP_ID_ANDROID'),
    messagingSenderId: _requireEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _requireEnv('FIREBASE_PROJECT_ID'),
    storageBucket: _envOrNull('FIREBASE_STORAGE_BUCKET'),
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _requireEnv('FIREBASE_API_KEY'),
    appId: _requireEnv('FIREBASE_APP_ID_IOS'),
    messagingSenderId: _requireEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _requireEnv('FIREBASE_PROJECT_ID'),
    storageBucket: _envOrNull('FIREBASE_STORAGE_BUCKET'),
    iosBundleId: _envOrNull('FIREBASE_IOS_BUNDLE_ID'),
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: _requireEnv('FIREBASE_API_KEY'),
    appId: _requireEnv('FIREBASE_APP_ID_IOS'),
    messagingSenderId: _requireEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _requireEnv('FIREBASE_PROJECT_ID'),
    storageBucket: _envOrNull('FIREBASE_STORAGE_BUCKET'),
    iosBundleId: _envOrNull('FIREBASE_IOS_BUNDLE_ID'),
  );

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: _requireEnv('FIREBASE_API_KEY'),
    appId: _requireEnv('FIREBASE_APP_ID_WINDOWS'),
    messagingSenderId: _requireEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _requireEnv('FIREBASE_PROJECT_ID'),
    authDomain: _envOrNull('FIREBASE_AUTH_DOMAIN'),
    storageBucket: _envOrNull('FIREBASE_STORAGE_BUCKET'),
    measurementId: _envOrNull('FIREBASE_MEASUREMENT_ID'),
  );

  static FirebaseOptions get linux => FirebaseOptions(
    apiKey: _requireEnv('FIREBASE_API_KEY'),
    appId: _requireEnv('FIREBASE_APP_ID_WINDOWS'),
    messagingSenderId: _requireEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _requireEnv('FIREBASE_PROJECT_ID'),
    authDomain: _envOrNull('FIREBASE_AUTH_DOMAIN'),
    storageBucket: _envOrNull('FIREBASE_STORAGE_BUCKET'),
    measurementId: _envOrNull('FIREBASE_MEASUREMENT_ID'),
  );

  static String _requireEnv(String key) {
    final value = dotenv.maybeGet(key);
    if (value == null || value.isEmpty) {
      throw StateError('Missing required .env key: $key');
    }
    return value;
  }

  static String? _envOrNull(String key) {
    final value = dotenv.maybeGet(key);
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}
