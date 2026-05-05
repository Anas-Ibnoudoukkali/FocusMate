import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/alarm_model.dart';

class AlarmStorageService {
  AlarmStorageService({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _alarmKey = 'focus_mate.local_alarm';

  final SharedPreferencesAsync _preferences;

  Future<AlarmModel> loadAlarm() async {
    final rawAlarm = await _preferences.getString(_alarmKey);

    if (rawAlarm == null || rawAlarm.isEmpty) {
      return _defaultAlarm();
    }

    final decoded = jsonDecode(rawAlarm);
    if (decoded is! Map<String, dynamic>) {
      return _defaultAlarm();
    }

    return AlarmModel.fromJson(decoded);
  }

  Future<void> saveAlarm(AlarmModel alarm) {
    return _preferences.setString(_alarmKey, jsonEncode(alarm.toJson()));
  }

  AlarmModel _defaultAlarm() {
    return const AlarmModel(
      id: 'local-alarm',
      hour: 7,
      minute: 0,
      challengeDifficulty: 'Medium',
    );
  }
}
