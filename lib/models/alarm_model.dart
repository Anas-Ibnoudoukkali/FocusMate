class AlarmModel {
  const AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    required this.challengeDifficulty,
    this.enabled = true,
    this.soundName = 'Bright Morning',
    this.repeatingDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    this.selectedDates = const [],
    this.challenges = const ['math'],
    this.createdAt,
  });

  final String id;
  final int hour;
  final int minute;
  final bool enabled;
  final String soundName;
  final String challengeDifficulty;
  final List<String> repeatingDays;
  final List<DateTime> selectedDates;
  final List<String> challenges;
  final DateTime? createdAt;

  AlarmModel copyWith({
    String? id,
    int? hour,
    int? minute,
    bool? enabled,
    String? soundName,
    String? challengeDifficulty,
    List<String>? repeatingDays,
    List<DateTime>? selectedDates,
    List<String>? challenges,
    DateTime? createdAt,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
      soundName: soundName ?? this.soundName,
      challengeDifficulty: challengeDifficulty ?? this.challengeDifficulty,
      repeatingDays: repeatingDays ?? this.repeatingDays,
      selectedDates: selectedDates ?? this.selectedDates,
      challenges: challenges ?? this.challenges,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    final sound = json['soundName'] ?? json['sound'];
    final difficulty = json['challengeDifficulty'] ?? json['difficulty'];
    final repeatDays = json['repeatingDays'] ?? json['repeatDays'];
    final isActive = json['enabled'] ?? json['isActive'];
    final timeParts = _parseTimeParts(json['time']);

    return AlarmModel(
      id: json['id'] as String? ?? 'local-alarm',
      hour: (json['hour'] as num?)?.toInt() ?? timeParts.$1,
      minute: (json['minute'] as num?)?.toInt() ?? timeParts.$2,
      enabled: isActive as bool? ?? true,
      soundName: sound as String? ?? 'Bright Morning',
      challengeDifficulty: difficulty as String? ?? 'Medium',
      repeatingDays: (repeatDays as List?)?.whereType<String>().toList() ??
          const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      selectedDates: _parseSelectedDates(json['selectedDates']),
      challenges: (json['challenges'] as List?)?.whereType<String>().toList() ??
          const ['math'],
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final formattedTime = '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
    final formattedDifficulty = challengeDifficulty.toLowerCase();
    final sortedDates = selectedDates.toList()..sort();

    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'time': formattedTime,
      'enabled': enabled,
      'isActive': enabled,
      'soundName': soundName,
      'sound': soundName,
      'challengeDifficulty': challengeDifficulty,
      'difficulty': formattedDifficulty,
      'repeatingDays': repeatingDays,
      'repeatDays': repeatingDays,
      'selectedDates': sortedDates.map(_formatDateOnly).toList(),
      'challenges': challenges,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  DateTime nextOccurrence({DateTime? from}) {
    final now = from ?? DateTime.now();

    final upcomingSelectedDates = selectedDates
        .map(_normalizeDate)
        .map((date) => DateTime(date.year, date.month, date.day, hour, minute))
        .where((scheduled) => scheduled.isAfter(now))
        .toList()
      ..sort();

    if (upcomingSelectedDates.isNotEmpty) {
      return upcomingSelectedDates.first;
    }

    final activeDays = repeatingDays.isEmpty
        ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : repeatingDays;

    for (var dayOffset = 0; dayOffset <= 7; dayOffset += 1) {
      final date = now.add(Duration(days: dayOffset));
      final scheduled = DateTime(date.year, date.month, date.day, hour, minute);

      if (scheduled.isAfter(now) &&
          activeDays.contains(_weekdayKey(scheduled.weekday))) {
        return scheduled;
      }
    }

    return DateTime(now.year, now.month, now.day, hour, minute)
        .add(const Duration(days: 1));
  }

  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '${displayHour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')} $period';
  }

  String _weekdayKey(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
      default:
        return 'Sun';
    }
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String _formatDateOnly(DateTime date) {
    final normalized = _normalizeDate(date);
    return '${normalized.year.toString().padLeft(4, '0')}-'
        '${normalized.month.toString().padLeft(2, '0')}-'
        '${normalized.day.toString().padLeft(2, '0')}';
  }

  static List<DateTime> _parseSelectedDates(Object? rawDates) {
    if (rawDates is! List) {
      return const [];
    }

    return rawDates
        .map(_parseDateTime)
        .whereType<DateTime>()
        .map(_normalizeDate)
        .toSet()
        .toList()
      ..sort();
  }

  static DateTime? _parseDateTime(Object? rawDate) {
    if (rawDate == null) {
      return null;
    }
    if (rawDate is DateTime) {
      return rawDate;
    }
    if (rawDate is String) {
      return DateTime.tryParse(rawDate);
    }
    final maybeToDate = rawDate as dynamic;
    try {
      final converted = maybeToDate.toDate();
      if (converted is DateTime) {
        return converted;
      }
    } on Object {
      return null;
    }
    return null;
  }

  static (int, int) _parseTimeParts(Object? rawTime) {
    if (rawTime is! String || !rawTime.contains(':')) {
      return (7, 0);
    }

    final parts = rawTime.split(':');
    final hour = int.tryParse(parts.first) ?? 7;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;

    return (hour.clamp(0, 23).toInt(), minute.clamp(0, 59).toInt());
  }
}
