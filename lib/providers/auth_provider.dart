import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService) {
    _subscription = _authService.authStateChanges.listen(
      (user) {
        _firebaseUser = user;
        _isInitializing = false;
        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = _friendlyAuthMessage(error);
        _isInitializing = false;
        notifyListeners();
      },
    );
  }

  final AuthService _authService;
  StreamSubscription<User?>? _subscription;

  User? _firebaseUser;
  bool _isInitializing = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  bool get isInitializing => _isInitializing;
  bool get isLoading => _isSubmitting;
  bool get isAuthenticated => _firebaseUser != null;
  String? get errorMessage => _errorMessage;
  String get displayName =>
      _firebaseUser?.displayName?.trim().isNotEmpty == true
          ? _firebaseUser!.displayName!
          : 'Student';
  String get email => _firebaseUser?.email ?? '';
  String get uid => _firebaseUser?.uid ?? '';

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(
      () => _authService.signIn(email: email, password: password),
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _runAuthAction(
      () => _authService.register(name: name, email: email, password: password),
    );
  }

  Future<bool> sendPasswordReset(String email) async {
    return _runAuthAction(() => _authService.sendPasswordReset(email));
  }

  Future<bool> updateDisplayName(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      _errorMessage = 'Name cannot be empty.';
      notifyListeners();
      return false;
    }

    return _runAuthAction(() async {
      await _authService.updateDisplayName(cleanName);
      _firebaseUser = _authService.currentUser;
    });
  }

  Future<void> signOut() async {
    clearError();
    await _authService.signOut();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runAuthAction(Future<dynamic> Function() action) async {
    _setSubmitting(true);
    _errorMessage = null;

    try {
      await action();
      _setSubmitting(false);
      return true;
    } on Object catch (error) {
      _errorMessage = _friendlyAuthMessage(error);
      _setSubmitting(false);
      return false;
    }
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  String _friendlyAuthMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'That email address does not look right.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email or password is incorrect.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'weak-password':
          return 'Choose a stronger password.';
        case 'network-request-failed':
          return 'Network connection failed. Try again.';
        default:
          return error.message ?? 'Authentication failed. Try again.';
      }
    }

    return 'Something went wrong. Try again.';
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
