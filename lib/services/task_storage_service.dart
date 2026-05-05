import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';

class TaskStorageService {
  TaskStorageService({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _tasksKey = 'focus_mate.local_tasks';

  final SharedPreferencesAsync _preferences;

  Future<List<TaskModel>> loadTasks() async {
    final rawTasks = await _preferences.getString(_tasksKey);

    if (rawTasks == null || rawTasks.isEmpty) {
      return _seedTasks();
    }

    final decoded = jsonDecode(rawTasks);
    if (decoded is! List) {
      return _seedTasks();
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(TaskModel.fromJson)
        .where((task) => task.id.isNotEmpty && task.title.isNotEmpty)
        .toList();
  }

  Future<void> saveTasks(List<TaskModel> tasks) {
    final encoded = jsonEncode(
      tasks.map((task) => task.toJson()).toList(growable: false),
    );

    return _preferences.setString(_tasksKey, encoded);
  }

  List<TaskModel> _seedTasks() {
    final now = DateTime.now();

    return [
      TaskModel(
        id: 'seed-biology',
        title: 'Review Chapter 5 - Cell Structure',
        subject: 'Biology',
        estimatedMinutes: 45,
        createdAt: now.subtract(const Duration(minutes: 4)),
        isCompleted: true,
      ),
      TaskModel(
        id: 'seed-calculus',
        title: 'Solve Calculus Problem Set',
        subject: 'Mathematics',
        estimatedMinutes: 60,
        createdAt: now.subtract(const Duration(minutes: 3)),
      ),
      TaskModel(
        id: 'seed-psychology',
        title: 'Read: The Psychology of Learning',
        subject: 'Psychology',
        estimatedMinutes: 30,
        createdAt: now.subtract(const Duration(minutes: 2)),
      ),
      TaskModel(
        id: 'seed-spanish',
        title: 'Flashcards - Spanish Vocabulary',
        subject: 'Spanish',
        estimatedMinutes: 25,
        createdAt: now.subtract(const Duration(minutes: 1)),
        isCompleted: true,
      ),
    ];
  }
}
