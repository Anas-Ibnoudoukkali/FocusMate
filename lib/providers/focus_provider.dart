import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/focus_session_model.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/focus_session_storage_service.dart';
import 'settings_provider.dart';
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
    required SettingsProvider settingsProvider,
    FirestoreService? firestoreService,
    AuthService? authService,
  })  : _storageService = storageService,
        _taskProvider = taskProvider,
        _settingsProvider = settingsProvider,
        _firestoreService = firestoreService,
        _authService = authService {
    _settingsProvider.addListener(_handleSettingsChanged);
    _authSubscription = _authService?.authStateChanges.listen(
      _handleAuthChanged,
      onError: (_) {
        _errorMessage = 'Could not sync focus sessions with your account.';
        notifyListeners();
      },
    );
    loadSessions();
    _resetToDefaultDuration();
  }

  final FocusSessionStorageService _storageService;
  final TaskProvider _taskProvider;
  final SettingsProvider _settingsProvider;
  final FirestoreService? _firestoreService;
  final AuthService? _authService;

  Timer? _timer;
  StreamSubscription<User?>? _authSubscription;
  List<FocusSessionModel> _sessions = [];
  TaskModel? _selectedTask;
  FocusSessionStatus _status = FocusSessionStatus.idle;
  DateTime? _startedAt;
  int _durationSeconds = 0;
  int _remainingSeconds = 0;
  int _distractions = 0;
  int _exitAttempts = 0;
  bool _isLoadingSessions = true;
  bool _isSaving = false;
  String? _errorMessage;
  FocusSessionModel? _lastSession;

  List<FocusSessionModel> get sessions => List.unmodifiable(_sessions);
  TaskModel? get selectedTask => _selectedTask;
  FocusSessionStatus get status => _status;
  FocusSessionModel? get lastSession => _lastSession;
  bool get isLoadingSessions => _isLoadingSessions;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  int get defaultDurationSeconds =>
      _settingsProvider.defaultFocusDuration * 60;
  int get durationSeconds {
    if (_selectedTask == null && !isActive && !isReview) {
      return defaultDurationSeconds;
    }
    return _durationSeconds == 0 ? defaultDurationSeconds : _durationSeconds;
  }

  int get remainingSeconds {
    if (_selectedTask == null && !isActive && !isReview) {
      return defaultDurationSeconds;
    }
    return _durationSeconds == 0 ? defaultDurationSeconds : _remainingSeconds;
  }
  int get distractions => _distractions;
  int get exitAttempts => _exitAttempts;
  int get elapsedSeconds => durationSeconds - remainingSeconds;
  bool get hasSelectedTask => _selectedTask != null;
  bool get strictMode => _settingsProvider.strictMode;
  bool get isActive =>
      _status == FocusSessionStatus.running ||
      _status == FocusSessionStatus.paused;
  bool get isRunning => _status == FocusSessionStatus.running;
  bool get isPaused => _status == FocusSessionStatus.paused;
  bool get isReview => _status == FocusSessionStatus.review;
  double get progress {
    if (durationSeconds == 0) {
      return 0;
    }
    return (elapsedSeconds / durationSeconds).clamp(0, 1).toDouble();
  }

  String get formattedRemaining => _formatSeconds(remainingSeconds);
  String get formattedDuration => _formatDuration(durationSeconds);

  int get totalFocusSeconds => _sessions.fold<int>(
        0,
        (total, session) => total + session.elapsedSeconds,
      );

  int get completedSessions =>
      _sessions.where((session) => session.completed).length;

  int get totalDistractions => _sessions.fold<int>(
        0,
        (total, session) => total + session.distractions,
      );

  int get totalExitAttempts => _sessions.fold<int>(
        0,
        (total, session) => total + session.exitAttempts,
      );

  double get completionRate =>
      _sessions.isEmpty ? 0 : completedSessions / _sessions.length;

  int get todayFocusSeconds {
    final now = DateTime.now();
    return _sessions
        .where((session) => _isSameDay(session.endedAt, now))
        .fold<int>(0, (total, session) => total + session.elapsedSeconds);
  }

  int get todaySessions {
    final now = DateTime.now();
    return _sessions.where((session) => _isSameDay(session.endedAt, now)).length;
  }

  int get todayDistractions {
    final now = DateTime.now();
    return _sessions
        .where((session) => _isSameDay(session.endedAt, now))
        .fold<int>(0, (total, session) => total + session.distractions);
  }

  double get dailyGoalProgress {
    final goalSeconds = _settingsProvider.dailyGoalMinutes * 60;
    if (goalSeconds == 0) {
      return 0;
    }
    return (todayFocusSeconds / goalSeconds).clamp(0, 1).toDouble();
  }

  List<int> get weeklyFocusSeconds {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final values = List<int>.filled(7, 0);

    for (final session in _sessions) {
      final sessionDay = DateTime(
        session.endedAt.year,
        session.endedAt.month,
        session.endedAt.day,
      );
      final offset = sessionDay.difference(startOfWeek).inDays;
      if (offset >= 0 && offset < values.length) {
        values[offset] += session.elapsedSeconds;
      }
    }

    return values;
  }

  int get currentStreak {
    final activeDays = _sessions
        .where((session) => session.elapsedSeconds > 0)
        .map((session) => _dateKey(session.endedAt))
        .toSet();
    var cursor = DateTime.now();
    var streak = 0;

    while (activeDays.contains(_dateKey(cursor))) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<void> loadSessions() async {
    _isLoadingSessions = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _currentUid;
      final firestore = _firestoreService;

      if (uid != null && firestore != null) {
        _sessions = await firestore.loadFocusSessions(uid);
      } else {
        _sessions = await _storageService.loadSessions();
      }
    } on Object {
      _errorMessage = _isCloudMode
          ? 'Could not load cloud focus sessions.'
          : 'Could not load focus sessions.';
    } finally {
      _isLoadingSessions = false;
      notifyListeners();
    }
  }

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
      startDefaultSession();
      return;
    }
    startSession(task);
  }

  void startDefaultSession() {
    startSession(
      TaskModel(
        id: 'quick-focus-${DateTime.now().microsecondsSinceEpoch}',
        title: 'Quick Focus',
        subject: 'Study Goal',
        estimatedMinutes: _settingsProvider.defaultFocusDuration,
        createdAt: DateTime.now(),
      ),
    );
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
      final uid = _currentUid;
      final firestore = _firestoreService;

      if (uid != null && firestore != null) {
        await firestore.saveFocusSession(uid, session);
      } else {
        await _storageService.saveSession(session);
      }
      _sessions = [..._sessions, session];
      if (completed && !_isQuickFocusTask(task)) {
        await _taskProvider.markTaskCompleted(task.id);
      }
      _lastSession = session;
      _status = FocusSessionStatus.review;
      _errorMessage = null;
    } on Object {
      _errorMessage = _isCloudMode
          ? 'Could not save focus session to your account.'
          : 'Could not save focus session.';
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
    _authSubscription?.cancel();
    _settingsProvider.removeListener(_handleSettingsChanged);
    super.dispose();
  }

  String? get _currentUid => _authService?.currentUser?.uid;
  bool get _isCloudMode => _currentUid != null && _firestoreService != null;

  void _handleAuthChanged(User? user) {
    if (isActive) {
      return;
    }
    loadSessions();
  }

  void _resetToDefaultDuration() {
    if (_selectedTask != null || isActive || isReview) {
      return;
    }
    _durationSeconds = defaultDurationSeconds;
    _remainingSeconds = defaultDurationSeconds;
  }

  void _handleSettingsChanged() {
    _resetToDefaultDuration();
    notifyListeners();
  }

  bool _isQuickFocusTask(TaskModel task) {
    return task.id.startsWith('quick-focus-');
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}
