import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/focus_session_model.dart';

class FocusSessionStorageService {
  FocusSessionStorageService({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _sessionsKey = 'focus_mate.focus_sessions';

  final SharedPreferencesAsync _preferences;

  Future<List<FocusSessionModel>> loadSessions() async {
    final rawSessions = await _preferences.getString(_sessionsKey);

    if (rawSessions == null || rawSessions.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(rawSessions);
    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(FocusSessionModel.fromJson)
        .where((session) => session.id.isNotEmpty)
        .toList();
  }

  Future<void> saveSession(FocusSessionModel session) async {
    final sessions = await loadSessions();
    final updatedSessions = [...sessions, session];
    final encoded = jsonEncode(
      updatedSessions.map((item) => item.toJson()).toList(growable: false),
    );

    await _preferences.setString(_sessionsKey, encoded);
  }
}
