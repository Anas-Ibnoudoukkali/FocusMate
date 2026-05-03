class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.estimatedMinutes,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String subject;
  final int estimatedMinutes;
  final bool isCompleted;
}
