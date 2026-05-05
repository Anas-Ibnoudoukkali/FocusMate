import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/focus_session_model.dart';
import '../models/task_model.dart';
import '../services/focus_session_storage_service.dart';
import 'task_provider.dart';

enum FocusSessionStatus {
  idle,
  running,
  paused,
  review,
}

class FocusProvider extends ChangeNotifier {
  FocusProvider({
    required FocusSessionStorageService storageService,
    required TaskProvider taskProvider,
  })  : _storageService = storageService,
        _taskProvider = taskProvider;

  final FocusSessionStorageService _storageService;
  final TaskProvider _taskProvider;

  Timer? _timer;
  TaskModel? _selectedTask;
  FocusSessionStatus _status = FocusSessionStatus.idle;
  DateTime? _startedAt;
  int _durationSeconds = 0;
  int _remainingSeconds = 0;
  int _distractions = 0;
  int _exitAttempts = 0;
  bool _isSaving = false;
  String? _errorMessage;
  FocusSessionModel? _lastSession;

  TaskModel? get selectedTask => _selectedTask;
  FocusSessionStatus get status => _status;
  FocusSessionModel? get lastSession => _lastSession;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  int get durationSeconds => _durationSeconds;
  int get remainingSeconds => _remainingSeconds;
  int get distractions => _distractions;
  int get exitAttempts => _exitAttempts;
  int get elapsedSeconds => _durationSeconds - _remainingSeconds;
  bool get hasSelectedTask => _selectedTask != null;
  bool get isActive =>
      _status == FocusSessionStatus.running ||
      _status == FocusSessionStatus.paused;
  bool get isRunning => _status == FocusSessionStatus.running;
  bool get isPaused => _status == FocusSessionStatus.paused;
  bool get isReview => _status == FocusSessionStatus.review;
  double get progress {
    if (_durationSeconds == 0) {
      return 0;
    }
    return (elapsedSeconds / _durationSeconds).clamp(0, 1).toDouble();
  }

  String get formattedRemaining => _formatSeconds(_remainingSeconds);
  String get formattedDuration => _formatDuration(_durationSeconds);

  void selectTask(TaskModel task) {
    if (isActive) {
      return;
    }

    _selectedTask = task;
    _durationSeconds = task.estimatedMinutes * 60;
    _remainingSeconds = _durationSeconds;
    _distractions = 0;
    _exitAttempts = 0;
    _lastSession = null;
    _errorMessage = null;
    _status = FocusSessionStatus.idle;
    notifyListeners();
  }

  void startSelectedTask() {
    final task = _selectedTask;
    if (task == null) {
      return;
    }
    startSession(task);
  }

  void startSession(TaskModel task) {
    _timer?.cancel();
    _selectedTask = task;
    _startedAt = DateTime.now();
    _durationSeconds = task.estimatedMinutes * 60;
    _remainingSeconds = _durationSeconds;
    _distractions = 0;
    _exitAttempts = 0;
    _lastSession = null;
    _errorMessage = null;
    _status = FocusSessionStatus.running;
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (_status != FocusSessionStatus.running) {
      return;
    }

    _timer?.cancel();
    _status = FocusSessionStatus.paused;
    notifyListeners();
  }

  void resume() {
    if (_status != FocusSessionStatus.paused) {
      return;
    }

    _status = FocusSessionStatus.running;
    _startTicker();
    notifyListeners();
  }

  void addDistraction() {
    if (!isActive) {
      return;
    }

    _distractions += 1;
    notifyListeners();
  }

  Future<void> finishSession() async {
    if (!isActive) {
      return;
    }

    await _completeSession(completed: true);
  }

  Future<void> endSessionEarly() async {
    if (!isActive) {
      return;
    }

    _exitAttempts += 1;
    await _completeSession(completed: false);
  }

  void clearReview() {
    _status = FocusSessionStatus.idle;
    _lastSession = null;
    _selectedTask = null;
    _startedAt = null;
    _durationSeconds = 0;
    _remainingSeconds = 0;
    _distractions = 0;
    _exitAttempts = 0;
    _errorMessage = null;
    notifyListeners();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _remainingSeconds = 0;
        notifyListeners();
        finishSession();
        return;
      }

      _remainingSeconds -= 1;
      notifyListeners();
    });
  }

  Future<void> _completeSession({required bool completed}) async {
    final task = _selectedTask;
    if (task == null || _isSaving) {
      return;
    }

    _timer?.cancel();
    _isSaving = true;
    if (completed) {
      _remainingSeconds = 0;
    }
    notifyListeners();

    final now = DateTime.now();
    final session = FocusSessionModel(
      id: now.microsecondsSinceEpoch.toString(),
      taskId: task.id,
      taskTitle: task.title,
      subject: task.subject,
      durationMinutes: task.estimatedMinutes,
      elapsedSeconds: elapsedSeconds,
      startedAt: _startedAt ?? now,
      endedAt: now,
      distractions: _distractions,
      exitAttempts: _exitAttempts,
      completed: completed,
    );

    try {
      await _storageService.saveSession(session);
      if (completed) {
        await _taskProvider.markTaskCompleted(task.id);
      }
      _lastSession = session;
      _status = FocusSessionStatus.review;
      _errorMessage = null;
    } on Object {
      _errorMessage = 'Could not save focus session.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  String _formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    return '${minutes}m session';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
