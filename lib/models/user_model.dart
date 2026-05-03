import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.defaultFocusDuration = AppConstants.defaultFocusDuration,
    this.strictMode = AppConstants.defaultStrictMode,
    this.challengeDifficulty = AppConstants.defaultChallengeDifficulty,
    this.dailyGoalMinutes = AppConstants.defaultDailyGoalMinutes,
  });

  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final int defaultFocusDuration;
  final bool strictMode;
  final String challengeDifficulty;
  final int dailyGoalMinutes;

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};

    return UserModel(
      uid: data['uid'] as String? ?? snapshot.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      createdAt: _readDate(data['createdAt']),
      defaultFocusDuration:
          (data['defaultFocusDuration'] as num?)?.toInt() ??
              AppConstants.defaultFocusDuration,
      strictMode: data['strictMode'] as bool? ?? AppConstants.defaultStrictMode,
      challengeDifficulty: data['challengeDifficulty'] as String? ??
          AppConstants.defaultChallengeDifficulty,
      dailyGoalMinutes: (data['dailyGoalMinutes'] as num?)?.toInt() ??
          AppConstants.defaultDailyGoalMinutes,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'defaultFocusDuration': defaultFocusDuration,
      'strictMode': strictMode,
      'challengeDifficulty': challengeDifficulty,
      'dailyGoalMinutes': dailyGoalMinutes,
    };
  }

  Map<String, dynamic> toCreateFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'defaultFocusDuration': defaultFocusDuration,
      'strictMode': strictMode,
      'challengeDifficulty': challengeDifficulty,
      'dailyGoalMinutes': dailyGoalMinutes,
    };
  }

  static DateTime _readDate(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
