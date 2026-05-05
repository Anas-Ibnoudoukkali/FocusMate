class FocusSessionModel {
  const FocusSessionModel({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.subject,
    required this.durationMinutes,
    required this.elapsedSeconds,
    required this.startedAt,
    required this.endedAt,
    this.distractions = 0,
    this.exitAttempts = 0,
    this.completed = false,
  });

  final String id;
  final String taskId;
  final String taskTitle;
  final String subject;
  final int durationMinutes;
  final int elapsedSeconds;
  final DateTime startedAt;
  final DateTime endedAt;
  final int distractions;
  final int exitAttempts;
  final bool completed;

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) {
    return FocusSessionModel(
      id: json['id'] as String? ?? '',
      taskId: json['taskId'] as String? ?? '',
      taskTitle: json['taskTitle'] as String? ?? 'Focus Session',
      subject: json['subject'] as String? ?? 'Study',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 25,
      elapsedSeconds: (json['elapsedSeconds'] as num?)?.toInt() ?? 0,
      startedAt:
          DateTime.tryParse(json['startedAt'] as String? ?? '') ??
              DateTime.now(),
      endedAt:
          DateTime.tryParse(json['endedAt'] as String? ?? '') ??
              DateTime.now(),
      distractions: (json['distractions'] as num?)?.toInt() ?? 0,
      exitAttempts: (json['exitAttempts'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'subject': subject,
      'durationMinutes': durationMinutes,
      'elapsedSeconds': elapsedSeconds,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'distractions': distractions,
      'exitAttempts': exitAttempts,
      'completed': completed,
    };
  }
}
