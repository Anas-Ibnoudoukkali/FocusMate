class AlarmModel {
  const AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    required this.challengeDifficulty,
    this.enabled = true,
    this.soundName = 'Bright Morning',
    this.repeatingDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
  });

  final String id;
  final int hour;
  final int minute;
  final bool enabled;
  final String soundName;
  final String challengeDifficulty;
  final List<String> repeatingDays;

  AlarmModel copyWith({
    String? id,
    int? hour,
    int? minute,
    bool? enabled,
    String? soundName,
    String? challengeDifficulty,
    List<String>? repeatingDays,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
      soundName: soundName ?? this.soundName,
      challengeDifficulty: challengeDifficulty ?? this.challengeDifficulty,
      repeatingDays: repeatingDays ?? this.repeatingDays,
    );
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as String? ?? 'local-alarm',
      hour: (json['hour'] as num?)?.toInt() ?? 7,
      minute: (json['minute'] as num?)?.toInt() ?? 0,
      enabled: json['enabled'] as bool? ?? true,
      soundName: json['soundName'] as String? ?? 'Bright Morning',
      challengeDifficulty:
          json['challengeDifficulty'] as String? ?? 'Medium',
      repeatingDays: (json['repeatingDays'] as List?)
              ?.whereType<String>()
              .toList() ??
          const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'enabled': enabled,
      'soundName': soundName,
      'challengeDifficulty': challengeDifficulty,
      'repeatingDays': repeatingDays,
    };
  }

  DateTime nextOccurrence({DateTime? from}) {
    final now = from ?? DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '${displayHour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')} $period';
  }
}
