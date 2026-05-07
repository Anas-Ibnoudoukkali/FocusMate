import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AppGradientCard extends StatelessWidget {
  const AppGradientCard({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.child,
    this.padding = const EdgeInsets.all(24),
    this.gradient = AppColors.primaryGradient,
    this.borderRadius = 28,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final Gradient gradient;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [AppColors.glowShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || trailing != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle!,
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ?trailing,
              ],
            ),
          if (child != null) ...[
            if (title != null || trailing != null) const SizedBox(height: 18),
            child!,
          ],
        ],
      ),
    );
  }
}
