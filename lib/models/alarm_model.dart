class AlarmModel {
  const AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    required this.challengeDifficulty,
    this.enabled = true,
    this.repeatingDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
  });

  final String id;
  final int hour;
  final int minute;
  final bool enabled;
  final String challengeDifficulty;
  final List<String> repeatingDays;
}
