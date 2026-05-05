import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/task_model.dart';
import '../services/task_storage_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._storageService) {
    loadTasks();
  }

  final TaskStorageService _storageService;

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
  int get totalMinutes => _tasks.fold<int>(
        0,
        (total, task) => total + task.estimatedMinutes,
      );
  int get completedMinutes => _tasks
      .where((task) => task.isCompleted)
      .fold<int>(0, (total, task) => total + task.estimatedMinutes);
  int get dailyGoalMinutes => AppConstants.defaultDailyGoalMinutes;
  double get taskProgress =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;
  double get minuteProgress => dailyGoalMinutes == 0
      ? 0
      : (completedMinutes / dailyGoalMinutes).clamp(0, 1).toDouble();

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _storageService.loadTasks();
      _sortTasks();
    } on Object {
      _errorMessage = 'Could not load saved tasks.';
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
    await _persist();
  }

  Future<void> _persist() async {
    try {
      await _storageService.saveTasks(_tasks);
      _errorMessage = null;
    } on Object {
      _errorMessage = 'Could not save tasks locally.';
      notifyListeners();
    }
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.createdAt.compareTo(b.createdAt);
    });
  }
}
