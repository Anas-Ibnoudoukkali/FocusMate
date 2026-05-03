import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle display = TextStyle(
    fontSize: 42,
    height: 1.04,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 34,
    height: 1.08,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 24,
    height: 1.16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    height: 1.24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: AppColors.primary,
  );
}
