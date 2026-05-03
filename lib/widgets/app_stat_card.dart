import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor = AppColors.primary,
    this.iconBackground = AppColors.blueSoft,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color iconColor;
  final Color iconBackground;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [AppColors.softShadow],
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: iconColor, size: 30),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: AppTextStyles.body),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
