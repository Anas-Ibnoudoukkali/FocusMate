import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> createUserProfile(UserModel user) {
    return _users.doc(user.uid).set(user.toCreateFirestore());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    return UserModel.fromFirestore(snapshot);
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return UserModel.fromFirestore(snapshot);
    });
  }

  Future<void> updateUserSettings(
    String uid, {
    int? defaultFocusDuration,
    bool? strictMode,
    String? challengeDifficulty,
    int? dailyGoalMinutes,
  }) {
    final updates = <String, dynamic>{};

    if (defaultFocusDuration != null) {
      updates['defaultFocusDuration'] = defaultFocusDuration;
    }
    if (strictMode != null) {
      updates['strictMode'] = strictMode;
    }
    if (challengeDifficulty != null) {
      updates['challengeDifficulty'] = challengeDifficulty;
    }
    if (dailyGoalMinutes != null) {
      updates['dailyGoalMinutes'] = dailyGoalMinutes;
    }

    if (updates.isEmpty) {
      return Future<void>.value();
    }

    return _users.doc(uid).update(updates);
  }
}
