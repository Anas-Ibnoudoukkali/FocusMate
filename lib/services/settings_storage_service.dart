import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings_model.dart';

class SettingsStorageService {
  SettingsStorageService({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _settingsKey = 'focus_mate.app_settings';

  final SharedPreferencesAsync _preferences;

  Future<AppSettingsModel> loadSettings() async {
    final rawSettings = await _preferences.getString(_settingsKey);

    if (rawSettings == null || rawSettings.isEmpty) {
      return const AppSettingsModel();
    }

    final decoded = jsonDecode(rawSettings);
    if (decoded is! Map<String, dynamic>) {
      return const AppSettingsModel();
    }

    return AppSettingsModel.fromJson(decoded);
  }

  Future<void> saveSettings(AppSettingsModel settings) {
    return _preferences.setString(
      _settingsKey,
      jsonEncode(settings.toJson()),
    );
  }
}
