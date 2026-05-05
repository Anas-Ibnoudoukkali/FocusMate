class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.estimatedMinutes,
    required this.createdAt,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String subject;
  final int estimatedMinutes;
  final DateTime createdAt;
  final bool isCompleted;

  TaskModel copyWith({
    String? id,
    String? title,
    String? subject,
    int? estimatedMinutes,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? 'Study',
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 25,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.now(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'estimatedMinutes': estimatedMinutes,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}
