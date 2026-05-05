import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/alarm_model.dart';

class AlarmStorageService {
  AlarmStorageService({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _alarmKey = 'focus_mate.local_alarm';
  static const String _statsKey = 'focus_mate.alarm_stats';

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

  Future<AlarmStatsSnapshot> loadStats() async {
    final rawStats = await _preferences.getString(_statsKey);

    if (rawStats == null || rawStats.isEmpty) {
      return const AlarmStatsSnapshot();
    }

    final decoded = jsonDecode(rawStats);
    if (decoded is! Map<String, dynamic>) {
      return const AlarmStatsSnapshot();
    }

    return AlarmStatsSnapshot(
      attempts: (decoded['attempts'] as num?)?.toInt() ?? 0,
      successes: (decoded['successes'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> saveStats({
    required int attempts,
    required int successes,
  }) {
    return _preferences.setString(
      _statsKey,
      jsonEncode({
        'attempts': attempts,
        'successes': successes,
      }),
    );
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

class AlarmStatsSnapshot {
  const AlarmStatsSnapshot({
    this.attempts = 0,
    this.successes = 0,
  });

  final int attempts;
  final int successes;
}
