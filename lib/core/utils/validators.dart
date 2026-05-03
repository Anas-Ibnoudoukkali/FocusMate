class Validators {
  const Validators._();

  static String? requiredField(String? value, {String label = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name is too short';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (text.isEmpty) {
      return 'Email is required';
    }
    if (!emailPattern.hasMatch(text)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';

    if (text.isEmpty) {
      return 'Password is required';
    }
    if (text.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final passwordError = Validators.password(value);
    if (passwordError != null) {
      return passwordError;
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
