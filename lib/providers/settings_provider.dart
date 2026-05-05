import 'package:flutter/foundation.dart';

import '../models/app_settings_model.dart';
import '../services/settings_storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._storageService) {
    loadSettings();
  }

  final SettingsStorageService _storageService;

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
      _settings = await _storageService.loadSettings();
    } on Object {
      _errorMessage = 'Could not load settings.';
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

  Future<void> updateDarkMode(bool value) {
    return _update(_settings.copyWith(darkMode: value));
  }

  Future<void> _update(AppSettingsModel settings) async {
    _settings = settings;
    _errorMessage = null;
    notifyListeners();

    try {
      await _storageService.saveSettings(settings);
    } on Object {
      _errorMessage = 'Could not save settings.';
      notifyListeners();
    }
  }
}
