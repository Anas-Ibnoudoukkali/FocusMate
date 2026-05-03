import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color background = Color(0xFFF8FAFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardSoft = Color(0xFFF1F5FF);
  static const Color border = Color(0xFFE7ECF8);
  static const Color textPrimary = Color(0xFF060A27);
  static const Color textSecondary = Color(0xFF737EA6);
  static const Color textMuted = Color(0xFF98A1BD);
  static const Color primary = Color(0xFF235BFF);
  static const Color indigo = Color(0xFF5337F5);
  static const Color sky = Color(0xFF43A7FF);
  static const Color violet = Color(0xFF7659FF);
  static const Color success = Color(0xFF18B878);
  static const Color successSoft = Color(0xFFE8F8F1);
  static const Color warning = Color(0xFFFFA90A);
  static const Color warningSoft = Color(0xFFFFF4E3);
  static const Color danger = Color(0xFFE82E3B);
  static const Color dangerSoft = Color(0xFFFFECEE);
  static const Color purpleSoft = Color(0xFFF0ECFF);
  static const Color blueSoft = Color(0xFFEAF1FF);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sky, primary, indigo],
  );

  static const LinearGradient indigoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, indigo],
  );

  static BoxShadow get softShadow => BoxShadow(
        color: const Color(0xFFB8C2D8).withValues(alpha: 0.20),
        blurRadius: 24,
        offset: const Offset(0, 12),
      );

  static BoxShadow get glowShadow => BoxShadow(
        color: primary.withValues(alpha: 0.30),
        blurRadius: 28,
        offset: const Offset(0, 14),
      );
}
