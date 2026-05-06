import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/task_storage_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(
    this._storageService, {
    FirestoreService? firestoreService,
    AuthService? authService,
  })  : _firestoreService = firestoreService,
        _authService = authService {
    _authSubscription = _authService?.authStateChanges.listen(
      _handleAuthChanged,
      onError: (_) {
        _errorMessage = 'Could not sync tasks with your account.';
        notifyListeners();
      },
    );
    loadTasks();
  }

  final TaskStorageService _storageService;
  final FirestoreService? _firestoreService;
  final AuthService? _authService;
  StreamSubscription<User?>? _authSubscription;

  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalTasks => _tasks.length;
  int get completedTasks =>
      _tasks.where((task) => task.isCompleted).length;
  int get remainingTasks => totalTasks - completedTasks;
  String get completedTasksLabel => '$completedTasks/$totalTasks';
  int get totalMinutes => _tasks.fold<int>(
        0,
        (total, task) => total + task.estimatedMinutes,
      );
  int get completedMinutes => _tasks
      .where((task) => task.isCompleted)
      .fold<int>(0, (total, task) => total + task.estimatedMinutes);
  double get taskProgress =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _currentUid;
      final firestore = _firestoreService;

      if (uid != null && firestore != null) {
        _tasks = await firestore.loadTasks(uid);
      } else {
        _tasks = await _storageService.loadTasks();
      }
      _sortTasks();
    } on Object {
      _errorMessage = _isCloudMode
          ? 'Could not load cloud tasks.'
          : 'Could not load saved tasks.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String title,
    required String subject,
    required int estimatedMinutes,
  }) async {
    final task = TaskModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      subject: subject.trim().isEmpty ? 'Study' : subject.trim(),
      estimatedMinutes: estimatedMinutes,
      createdAt: DateTime.now(),
    );

    _tasks = [..._tasks, task];
    _sortTasks();
    notifyListeners();
    await _persist();
  }

  Future<void> toggleTask(String taskId) async {
    _tasks = _tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }
      return task.copyWith(isCompleted: !task.isCompleted);
    }).toList();

    _sortTasks();
    notifyListeners();
    await _persist();
  }

  Future<void> markTaskCompleted(String taskId) async {
    _tasks = _tasks.map((task) {
      if (task.id != taskId || task.isCompleted) {
        return task;
      }
      return task.copyWith(isCompleted: true);
    }).toList();

    _sortTasks();
    notifyListeners();
    await _persist();
  }

  Future<void> deleteTask(String taskId) async {
    _tasks = _tasks.where((task) => task.id != taskId).toList();
    notifyListeners();

    try {
      final uid = _currentUid;
      final firestore = _firestoreService;
      if (uid != null && firestore != null) {
        await firestore.deleteTask(uid, taskId);
        _errorMessage = null;
      } else {
        await _storageService.saveTasks(_tasks);
        _errorMessage = null;
      }
    } on Object {
      _errorMessage = _isCloudMode
          ? 'Could not delete task from your account.'
          : 'Could not delete task locally.';
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      final uid = _currentUid;
      final firestore = _firestoreService;

      if (uid != null && firestore != null) {
        await firestore.saveTasks(uid, _tasks);
      } else {
        await _storageService.saveTasks(_tasks);
      }
      _errorMessage = null;
    } on Object {
      _errorMessage = _isCloudMode
          ? 'Could not save tasks to your account.'
          : 'Could not save tasks locally.';
      notifyListeners();
    }
  }

  String? get _currentUid => _authService?.currentUser?.uid;
  bool get _isCloudMode => _currentUid != null && _firestoreService != null;

  void _handleAuthChanged(User? user) {
    loadTasks();
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
