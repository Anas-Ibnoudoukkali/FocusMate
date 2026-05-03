import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 20)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: AppTextStyles.body),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          DefaultTextStyle(
            style: AppTextStyles.label.copyWith(color: AppColors.primary),
            child: trailing!,
          ),
        ],
      ],
    );
  }
}
