import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/alarm_model.dart';
import '../services/alarm_storage_service.dart';

class AlarmProvider extends ChangeNotifier {
  AlarmProvider(this._storageService) {
    loadAlarm();
  }

  final AlarmStorageService _storageService;

  Timer? _alarmTimer;
  Timer? _soundTimer;
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
    final nextDate = DateTime(next.year, next.month, next.day);

    if (nextDate == tomorrow) {
      return 'Tomorrow';
    }
    return 'Today';
  }

  Future<void> loadAlarm() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _alarm = await _storageService.loadAlarm();
      final stats = await _storageService.loadStats();
      _alarmAttempts = stats.attempts;
      _alarmSuccesses = stats.successes;
      _scheduleForegroundAlarm();
    } on Object {
      _errorMessage = 'Could not load alarm.';
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
    );

    try {
      await _storageService.saveAlarm(updatedAlarm);
      _alarm = updatedAlarm;
      _errorMessage = null;
      _scheduleForegroundAlarm();
    } on Object {
      _errorMessage = 'Could not save alarm.';
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
    return _storageService.saveStats(
      attempts: _alarmAttempts,
      successes: _alarmSuccesses,
    );
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    _soundTimer?.cancel();
    super.dispose();
  }
}
