import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/alarm_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/focus_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'services/alarm_storage_service.dart';
import 'services/auth_service.dart';
import 'services/focus_session_storage_service.dart';
import 'services/firestore_service.dart';
import 'services/settings_storage_service.dart';
import 'services/storage_service.dart';
import 'services/task_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kEnableAuthFlow) {
    if (!DefaultFirebaseOptions.isConfigured) {
      throw StateError(
        'Firebase is not configured yet. Run flutterfire configure, then start '
        'the app with --dart-define=ENABLE_AUTH_FLOW=true.',
      );
    }

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<AlarmStorageService>(create: (_) => AlarmStorageService()),
        Provider<SettingsStorageService>(
          create: (_) => SettingsStorageService(),
        ),
        Provider<TaskStorageService>(create: (_) => TaskStorageService()),
        Provider<FocusSessionStorageService>(
          create: (_) => FocusSessionStorageService(),
        ),
        if (kEnableAuthFlow) ...[
          Provider<FirestoreService>(create: (_) => FirestoreService()),
          Provider<AuthService>(
            create: (context) => AuthService(
              firestoreService: context.read<FirestoreService>(),
            ),
          ),
          ChangeNotifierProvider<AuthProvider>(
            create: (context) => AuthProvider(context.read<AuthService>()),
          ),
        ],
        ChangeNotifierProvider<AlarmProvider>(
          create: (context) => AlarmProvider(
            context.read<AlarmStorageService>(),
            firestoreService:
                kEnableAuthFlow ? context.read<FirestoreService>() : null,
            authService: kEnableAuthFlow ? context.read<AuthService>() : null,
          ),
        ),
        ChangeNotifierProvider<TaskProvider>(
          create: (context) => TaskProvider(
            context.read<TaskStorageService>(),
            firestoreService:
                kEnableAuthFlow ? context.read<FirestoreService>() : null,
            authService: kEnableAuthFlow ? context.read<AuthService>() : null,
          ),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (context) => SettingsProvider(
            context.read<SettingsStorageService>(),
            firestoreService:
                kEnableAuthFlow ? context.read<FirestoreService>() : null,
            authService: kEnableAuthFlow ? context.read<AuthService>() : null,
          ),
        ),
        ChangeNotifierProvider<FocusProvider>(
          create: (context) => FocusProvider(
            storageService: context.read<FocusSessionStorageService>(),
            taskProvider: context.read<TaskProvider>(),
            settingsProvider: context.read<SettingsProvider>(),
            firestoreService:
                kEnableAuthFlow ? context.read<FirestoreService>() : null,
            authService: kEnableAuthFlow ? context.read<AuthService>() : null,
          ),
        ),
        ChangeNotifierProvider<NavigationProvider>(
          create: (_) => NavigationProvider(),
        ),
      ],
      child: const FocusMateApp(),
    ),
  );
}
