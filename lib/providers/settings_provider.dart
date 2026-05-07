import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_settings_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/settings_storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(
    this._storageService, {
    FirestoreService? firestoreService,
    AuthService? authService,
  })  : _firestoreService = firestoreService,
        _authService = authService {
    _authSubscription = _authService?.authStateChanges.listen(
      _handleAuthChanged,
      onError: (_) {
        _errorMessage = 'Could not sync settings with your account.';
        notifyListeners();
      },
    );
    loadSettings();
  }

  final SettingsStorageService _storageService;
  final FirestoreService? _firestoreService;
  final AuthService? _authService;
  StreamSubscription<User?>? _authSubscription;

  AppSettingsModel _settings = const AppSettingsModel();
  bool _isLoading = true;
  String? _errorMessage;

  AppSettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get defaultFocusDuration => _settings.defaultFocusDuration;
  bool get strictMode => _settings.strictMode;
  String get alarmSound => _settings.alarmSound;
  String get challengeDifficulty => _settings.challengeDifficulty;
  bool get darkMode => _settings.darkMode;
  int get dailyGoalMinutes => _settings.dailyGoalMinutes;

  Future<void> loadSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _currentUid;
      final firestore = _firestoreService;

      if (uid != null && firestore != null) {
        _settings = await firestore.loadSettings(uid);
        await _storageService.saveSettings(_settings);
      } else {
        _settings = await _storageService.loadSettings();
      }
    } on Object {
      _errorMessage = _isCloudMode
          ? 'Could not load cloud settings.'
          : 'Could not load settings.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDefaultFocusDuration(int minutes) {
    return _update(_settings.copyWith(defaultFocusDuration: minutes));
  }

  Future<void> updateStrictMode(bool value) {
    return _update(_settings.copyWith(strictMode: value));
  }

  Future<void> updateAlarmSound(String value) {
    return _update(_settings.copyWith(alarmSound: value));
  }

  Future<void> updateChallengeDifficulty(String value) {
    return _update(_settings.copyWith(challengeDifficulty: value));
  }

  Future<void> updateDailyGoalMinutes(int minutes) {
    return _update(_settings.copyWith(dailyGoalMinutes: minutes));
  }

  Future<void> updateDarkMode(bool value) {
    return _update(_settings.copyWith(darkMode: value));
  }

  Future<void> _update(AppSettingsModel settings) async {
    _settings = settings;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _currentUid;
      final firestore = _firestoreService;

      if (uid != null && firestore != null) {
        await firestore.saveSettings(uid, settings);
      }
      await _storageService.saveSettings(settings);
    } on Object {
      _errorMessage = _isCloudMode
          ? 'Could not save settings to your account.'
          : 'Could not save settings.';
      notifyListeners();
    }
  }

  String? get _currentUid => _authService?.currentUser?.uid;
  bool get _isCloudMode => _currentUid != null && _firestoreService != null;

  void _handleAuthChanged(User? user) {
    loadSettings();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
