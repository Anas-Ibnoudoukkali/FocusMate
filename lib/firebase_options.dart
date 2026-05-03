// Temporary FlutterFire options placeholder.
//
// Run `flutterfire configure` after creating your Firebase project. The command
// will generate the real values for this file and configure google-services.json
// / GoogleService-Info.plist for Android and iOS.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
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
    apiKey: 'REPLACE_WITH_FIREBASE_WEB_API_KEY',
    appId: 'REPLACE_WITH_FIREBASE_WEB_APP_ID',
    messagingSenderId: 'REPLACE_WITH_FIREBASE_SENDER_ID',
    projectId: 'REPLACE_WITH_FIREBASE_PROJECT_ID',
    authDomain: 'REPLACE_WITH_FIREBASE_PROJECT_ID.firebaseapp.com',
    storageBucket: 'REPLACE_WITH_FIREBASE_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_ANDROID_API_KEY',
    appId: 'REPLACE_WITH_FIREBASE_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_WITH_FIREBASE_SENDER_ID',
    projectId: 'REPLACE_WITH_FIREBASE_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_FIREBASE_PROJECT_ID.appspot.com',
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
}
