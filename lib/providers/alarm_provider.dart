import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/alarm_model.dart';
import '../services/alarm_storage_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AlarmProvider extends ChangeNotifier {
  AlarmProvider(
    this._storageService, {
    FirestoreService? firestoreService,
    AuthService? authService,
  })  : _firestoreService = firestoreService,
        _authService = authService {
    _authSubscription = _authService?.authStateChanges.listen(
      _handleAuthChanged,
      onError: (_) {
        _errorMessage = 'Could not sync alarm with your account.';
        notifyListeners();
      },
    );
    loadAlarm();
  }

  final AlarmStorageService _storageService;
  final FirestoreService? _firestoreService;
  final AuthService? _authService;

  Timer? _alarmTimer;
  Timer? _soundTimer;
  StreamSubscription<User?>? _authSubscription;
  AlarmModel? _alarm;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isRinging = false;
  int _leftOperand = 4;
  int _rightOperand = 7;
  int _alarmAttempts = 0;
  int _alarmSuccesses = 0;
  String? _errorMessage;

  AlarmModel? get alarm => _alarm;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isRinging => _isRinging;
  String? get errorMessage => _errorMessage;
  String get challengeQuestion => '$_leftOperand + $_rightOperand';
  int get challengeAnswer => _leftOperand + _rightOperand;
  int get alarmAttempts => _alarmAttempts;
  int get alarmSuccesses => _alarmSuccesses;
  double get alarmSuccessRate =>
      _alarmAttempts == 0 ? 0 : _alarmSuccesses / _alarmAttempts;
  String get alarmSuccessLabel =>
      _alarmAttempts == 0 ? 'No data' : '${(alarmSuccessRate * 100).round()}%';
  String get nextAlarmLabel {
    final currentAlarm = _alarm;
    if (currentAlarm == null || !currentAlarm.enabled) {
      return 'Not set';
    }
    return currentAlarm.formattedTime;
  }

  String get nextAlarmSubtitle {
    final currentAlarm = _alarm;
    if (currentAlarm == null || !currentAlarm.enabled) {
      return 'Tap to set alarm';
    }

    final next = currentAlarm.nextOccurrence();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final today = DateTime(now.year, now.month, now.day);
    final nextDate = DateTime(next.year, next.month, next.day);

    if (nextDate == today) {
      return 'Today';
    }
    if (nextDate == tomorrow) {
      return 'Tomorrow';
    }
    return _weekdayLabel(next.weekday);
  }

  Future<void> loadAlarm() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _currentUid;
      final firestore = _firestoreService;

      if (uid != null && firestore != null) {
        _alarm =
            await firestore.loadAlarm(uid) ?? await _storageService.loadAlarm();
        final stats = await firestore.loadAlarmStats(uid);
        _alarmAttempts = stats['attempts'] ?? 0;
        _alarmSuccesses = stats['successes'] ?? 0;
      } else {
        _alarm = await _storageService.loadAlarm();
        final stats = await _storageService.loadStats();
        _alarmAttempts = stats.attempts;
        _alarmSuccesses = stats.successes;
      }
      _scheduleForegroundAlarm();
    } on Object {
      _errorMessage =
          _isCloudMode ? 'Could not load cloud alarm.' : 'Could not load alarm.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveAlarm({
    required int hour,
    required int minute,
    required bool enabled,
    required String soundName,
    required String challengeDifficulty,
    required List<String> repeatingDays,
    required List<DateTime> selectedDates,
  }) async {
    _isSaving = true;
    notifyListeners();

    final updatedAlarm = AlarmModel(
      id: _alarm?.id ?? 'local-alarm',
      hour: hour,
      minute: minute,
      enabled: enabled,
      soundName: soundName,
      challengeDifficulty: challengeDifficulty,
      repeatingDays: repeatingDays,
      selectedDates: selectedDates,
      challenges: _alarm?.challenges ?? const ['math'],
      createdAt: _alarm?.createdAt,
    );

    try {
      final uid = _currentUid;
      final firestore = _firestoreService;

      if (uid != null && firestore != null) {
        await firestore.saveAlarm(uid, updatedAlarm);
        await firestore.saveAlarmStats(
          uid,
          attempts: _alarmAttempts,
          successes: _alarmSuccesses,
        );
      } else {
        await _storageService.saveAlarm(updatedAlarm);
        await _storageService.saveStats(
          attempts: _alarmAttempts,
          successes: _alarmSuccesses,
        );
      }
      _alarm = updatedAlarm;
      _errorMessage = null;
      _scheduleForegroundAlarm();
    } on Object {
      _errorMessage = _isCloudMode
          ? 'Could not save alarm to your account.'
          : 'Could not save alarm.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> applySettings({
    String? soundName,
    String? challengeDifficulty,
  }) {
    final currentAlarm = _alarm ??
        const AlarmModel(
          id: 'local-alarm',
          hour: 7,
          minute: 0,
          challengeDifficulty: 'Medium',
        );

    return saveAlarm(
      hour: currentAlarm.hour,
      minute: currentAlarm.minute,
      enabled: currentAlarm.enabled,
      soundName: soundName ?? currentAlarm.soundName,
      challengeDifficulty:
          challengeDifficulty ?? currentAlarm.challengeDifficulty,
      repeatingDays: currentAlarm.repeatingDays,
      selectedDates: currentAlarm.selectedDates,
    );
  }

  void triggerAlarmManually() {
    _startRinging();
  }

  bool tryStopAlarm(String answer) {
    if (int.tryParse(answer.trim()) != challengeAnswer) {
      _errorMessage = 'Solve the challenge to stop the alarm.';
      notifyListeners();
      return false;
    }

    _stopRinging();
    _alarmSuccesses += 1;
    _persistStats();
    notifyListeners();
    return true;
  }

  void _scheduleForegroundAlarm() {
    _alarmTimer?.cancel();

    final currentAlarm = _alarm;
    if (currentAlarm == null || !currentAlarm.enabled) {
      return;
    }

    final delay = currentAlarm.nextOccurrence().difference(DateTime.now());
    _alarmTimer = Timer(delay, _startRinging);
  }

  void _startRinging() {
    if (_isRinging) {
      return;
    }

    _generateChallenge();
    _isRinging = true;
    _alarmAttempts += 1;
    _errorMessage = null;
    _persistStats();
    _playAlarmSound();
    _soundTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _playAlarmSound(),
    );
    notifyListeners();
  }

  void _stopRinging() {
    _soundTimer?.cancel();
    _isRinging = false;
    _errorMessage = null;
    _scheduleForegroundAlarm();
    notifyListeners();
  }

  void _generateChallenge() {
    final random = Random();
    final difficulty = _alarm?.challengeDifficulty ?? 'Medium';
    final max = difficulty == 'Hard'
        ? 30
        : difficulty == 'Easy'
            ? 9
            : 18;

    _leftOperand = random.nextInt(max) + 1;
    _rightOperand = random.nextInt(max) + 1;
  }

  void _playAlarmSound() {
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
  }

  Future<void> _persistStats() {
    final uid = _currentUid;
    final firestore = _firestoreService;

    if (uid != null && firestore != null) {
      return firestore.saveAlarmStats(
        uid,
        attempts: _alarmAttempts,
        successes: _alarmSuccesses,
      );
    }

    return _storageService.saveStats(
      attempts: _alarmAttempts,
      successes: _alarmSuccesses,
    );
  }

  String? get _currentUid => _authService?.currentUser?.uid;
  bool get _isCloudMode => _currentUid != null && _firestoreService != null;

  void _handleAuthChanged(User? user) {
    loadAlarm();
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
      default:
        return 'Sunday';
    }
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    _soundTimer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
