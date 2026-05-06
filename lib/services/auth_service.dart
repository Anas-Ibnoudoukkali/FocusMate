import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirestoreService? firestoreService,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestoreService = firestoreService ?? FirestoreService();

  final FirebaseAuth _firebaseAuth;
  final FirestoreService _firestoreService;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Account was created but user data was unavailable.',
      );
    }

    await user.updateDisplayName(name.trim());

    final model = UserModel(
      uid: user.uid,
      name: name.trim(),
      email: email.trim(),
      createdAt: DateTime.now(),
      defaultFocusDuration: AppConstants.defaultFocusDuration,
      strictMode: AppConstants.defaultStrictMode,
      challengeDifficulty: AppConstants.defaultChallengeDifficulty,
      dailyGoalMinutes: AppConstants.defaultDailyGoalMinutes,
    );

    await _firestoreService.createUserProfile(model);
    return credential;
  }

  Future<void> sendPasswordReset(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> updateDisplayName(String name) async {
    final user = currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No connected user is available.',
      );
    }

    final cleanName = name.trim();
    await user.updateDisplayName(cleanName);
    await user.reload();
    await _firestoreService.updateUserProfileName(user.uid, cleanName);
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
