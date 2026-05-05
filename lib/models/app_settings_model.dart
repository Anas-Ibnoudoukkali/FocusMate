import '../core/constants/app_constants.dart';

class AppSettingsModel {
  const AppSettingsModel({
    this.defaultFocusDuration = AppConstants.defaultFocusDuration,
    this.strictMode = AppConstants.defaultStrictMode,
    this.alarmSound = 'Bright Morning',
    this.challengeDifficulty = AppConstants.defaultChallengeDifficulty,
    this.darkMode = false,
    this.dailyGoalMinutes = AppConstants.defaultDailyGoalMinutes,
  });

  final int defaultFocusDuration;
  final bool strictMode;
  final String alarmSound;
  final String challengeDifficulty;
  final bool darkMode;
  final int dailyGoalMinutes;

  AppSettingsModel copyWith({
    int? defaultFocusDuration,
    bool? strictMode,
    String? alarmSound,
    String? challengeDifficulty,
    bool? darkMode,
    int? dailyGoalMinutes,
  }) {
    return AppSettingsModel(
      defaultFocusDuration:
          defaultFocusDuration ?? this.defaultFocusDuration,
      strictMode: strictMode ?? this.strictMode,
      alarmSound: alarmSound ?? this.alarmSound,
      challengeDifficulty:
          challengeDifficulty ?? this.challengeDifficulty,
      darkMode: darkMode ?? this.darkMode,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    );
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      defaultFocusDuration:
          (json['defaultFocusDuration'] as num?)?.toInt() ??
              AppConstants.defaultFocusDuration,
      strictMode: json['strictMode'] as bool? ??
          AppConstants.defaultStrictMode,
      alarmSound: json['alarmSound'] as String? ?? 'Bright Morning',
      challengeDifficulty: json['challengeDifficulty'] as String? ??
          AppConstants.defaultChallengeDifficulty,
      darkMode: json['darkMode'] as bool? ?? false,
      dailyGoalMinutes: (json['dailyGoalMinutes'] as num?)?.toInt() ??
          AppConstants.defaultDailyGoalMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultFocusDuration': defaultFocusDuration,
      'strictMode': strictMode,
      'alarmSound': alarmSound,
      'challengeDifficulty': challengeDifficulty,
      'darkMode': darkMode,
      'dailyGoalMinutes': dailyGoalMinutes,
    };
  }
}
