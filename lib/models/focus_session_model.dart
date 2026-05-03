class FocusSessionModel {
  const FocusSessionModel({
    required this.id,
    required this.taskTitle,
    required this.durationMinutes,
    required this.startedAt,
    this.distractions = 0,
    this.exitAttempts = 0,
    this.completed = false,
  });

  final String id;
  final String taskTitle;
  final int durationMinutes;
  final DateTime startedAt;
  final int distractions;
  final int exitAttempts;
  final bool completed;
}
