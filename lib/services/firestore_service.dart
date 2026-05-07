import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/alarm_model.dart';
import '../models/app_settings_model.dart';
import '../models/focus_session_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> _tasks(String uid) {
    return _users.doc(uid).collection('tasks');
  }

  CollectionReference<Map<String, dynamic>> _focusSessions(String uid) {
    return _users.doc(uid).collection('focusSessions');
  }

  CollectionReference<Map<String, dynamic>> _alarms(String uid) {
    return _users.doc(uid).collection('alarms');
  }

  CollectionReference<Map<String, dynamic>> _stats(String uid) {
    return _users.doc(uid).collection('stats');
  }

  Future<void> createUserProfile(UserModel user) {
    return _users.doc(user.uid).set(user.toCreateFirestore());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    return UserModel.fromFirestore(snapshot);
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return UserModel.fromFirestore(snapshot);
    });
  }

  Future<void> updateUserSettings(
    String uid, {
    int? defaultFocusDuration,
    bool? strictMode,
    String? challengeDifficulty,
    int? dailyGoalMinutes,
    String? alarmSound,
    bool? darkMode,
  }) {
    final updates = <String, dynamic>{};

    if (defaultFocusDuration != null) {
      updates['defaultFocusDuration'] = defaultFocusDuration;
    }
    if (strictMode != null) {
      updates['strictMode'] = strictMode;
    }
    if (challengeDifficulty != null) {
      updates['challengeDifficulty'] = challengeDifficulty;
    }
    if (dailyGoalMinutes != null) {
      updates['dailyGoalMinutes'] = dailyGoalMinutes;
    }
    if (alarmSound != null) {
      updates['alarmSound'] = alarmSound;
    }
    if (darkMode != null) {
      updates['darkMode'] = darkMode;
    }

    if (updates.isEmpty) {
      return Future<void>.value();
    }

    return _users.doc(uid).update(updates);
  }

  Future<void> updateUserProfileName(String uid, String name) {
    return _users.doc(uid).update({
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<TaskModel>> loadTasks(String uid) async {
    final snapshot = await _tasks(uid).orderBy('createdAt').get();
    return snapshot.docs
        .map((doc) => TaskModel.fromJson({...doc.data(), 'id': doc.id}))
        .where((task) => task.id.isNotEmpty && task.title.isNotEmpty)
        .toList();
  }

  Stream<List<TaskModel>> watchTasks(String uid) {
    return _tasks(uid).orderBy('createdAt').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskModel.fromJson({...doc.data(), 'id': doc.id}))
          .where((task) => task.id.isNotEmpty && task.title.isNotEmpty)
          .toList();
    });
  }

  Future<void> saveTask(String uid, TaskModel task) {
    return _tasks(uid).doc(task.id).set(task.toJson());
  }

  Future<void> saveTasks(String uid, List<TaskModel> tasks) async {
    final batch = _firestore.batch();
    for (final task in tasks) {
      batch.set(_tasks(uid).doc(task.id), task.toJson());
    }
    await batch.commit();
  }

  Future<void> deleteTask(String uid, String taskId) {
    return _tasks(uid).doc(taskId).delete();
  }

  Future<List<FocusSessionModel>> loadFocusSessions(String uid) async {
    final snapshot = await _focusSessions(uid).orderBy('endedAt').get();
    return snapshot.docs
        .map((doc) => FocusSessionModel.fromJson({...doc.data(), 'id': doc.id}))
        .where((session) => session.id.isNotEmpty)
        .toList();
  }

  Stream<List<FocusSessionModel>> watchFocusSessions(String uid) {
    return _focusSessions(uid).orderBy('endedAt').snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => FocusSessionModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .where((session) => session.id.isNotEmpty)
          .toList();
    });
  }

  Future<void> saveFocusSession(String uid, FocusSessionModel session) {
    return _focusSessions(uid).doc(session.id).set(session.toJson());
  }

  Future<AlarmModel?> loadAlarm(String uid) async {
    final snapshot = await _alarms(uid).doc('primary').get();
    if (!snapshot.exists) {
      return null;
    }
    return AlarmModel.fromJson({...?snapshot.data(), 'id': snapshot.id});
  }

  Future<void> saveAlarm(String uid, AlarmModel alarm) async {
    final doc = _alarms(uid).doc('primary');
    final snapshot = await doc.get();
    final alarmData = alarm.toJson()..remove('createdAt');
    final data = {
      ...alarmData,
      'userId': uid,
      if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    return doc.set(data, SetOptions(merge: true));
  }

  Future<Map<String, int>> loadAlarmStats(String uid) async {
    final snapshot = await _stats(uid).doc('alarm').get();
    final data = snapshot.data();
    if (data == null) {
      return {'attempts': 0, 'successes': 0};
    }

    return {
      'attempts': (data['attempts'] as num?)?.toInt() ?? 0,
      'successes': (data['successes'] as num?)?.toInt() ?? 0,
    };
  }

  Future<void> saveAlarmStats(
    String uid, {
    required int attempts,
    required int successes,
  }) {
    return _stats(uid).doc('alarm').set({
      'attempts': attempts,
      'successes': successes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<AppSettingsModel> loadSettings(String uid) async {
    final snapshot = await _users.doc(uid).get();
    final data = snapshot.data();
    if (data == null) {
      return const AppSettingsModel();
    }

    return AppSettingsModel.fromJson(data);
  }

  Future<void> saveSettings(String uid, AppSettingsModel settings) {
    return updateUserSettings(
      uid,
      defaultFocusDuration: settings.defaultFocusDuration,
      strictMode: settings.strictMode,
      challengeDifficulty: settings.challengeDifficulty,
      dailyGoalMinutes: settings.dailyGoalMinutes,
      alarmSound: settings.alarmSound,
      darkMode: settings.darkMode,
    );
  }
}
