// Temporary FlutterFire options placeholder.
//
// Run `flutterfire configure` after creating your Firebase project. The command
// will generate the real values for this file and configure google-services.json
// / GoogleService-Info.plist for Android and iOS.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static bool get isConfigured {
    try {
      return !_hasPlaceholder(currentPlatform);
    } on UnsupportedError {
      return false;
    }
  }

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
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'FocusMate Firebase options are configured for mobile-first targets. '
          'Run FlutterFire CLI to add this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDCiQBKNn4Mbkx9pnDkqFQQXUekz2WpaO8',
    appId: '1:187991416212:web:5a0904047fc1c5563bc381',
    messagingSenderId: '187991416212',
    projectId: 'focusmate-89907',
    authDomain: 'focusmate-89907.firebaseapp.com',
    storageBucket: 'focusmate-89907.firebasestorage.app',
    measurementId: 'G-26XGCV8FV5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC7DnrzxW8wNulmTFnsxVF4uaU47VhAbYU',
    appId: '1:187991416212:android:597c8fab3fc14f033bc381',
    messagingSenderId: '187991416212',
    projectId: 'focusmate-89907',
    storageBucket: 'focusmate-89907.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_IOS_API_KEY',
    appId: 'REPLACE_WITH_FIREBASE_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_FIREBASE_SENDER_ID',
    projectId: 'REPLACE_WITH_FIREBASE_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_FIREBASE_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.focusMate',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_MACOS_API_KEY',
    appId: 'REPLACE_WITH_FIREBASE_MACOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_FIREBASE_SENDER_ID',
    projectId: 'REPLACE_WITH_FIREBASE_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_FIREBASE_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.focusMate',
  );

  static bool _hasPlaceholder(FirebaseOptions options) {
    return options.apiKey.startsWith('REPLACE_WITH_') ||
        options.appId.startsWith('REPLACE_WITH_') ||
        options.messagingSenderId.startsWith('REPLACE_WITH_') ||
        options.projectId.startsWith('REPLACE_WITH_');
  }
}
