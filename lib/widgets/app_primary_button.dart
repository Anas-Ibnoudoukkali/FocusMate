import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.isDestructive = false,
    this.isOutlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final bool isDestructive;
  final bool isOutlined;

  bool get _disabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final dangerSoft = AppColors.dangerSoftFor(context);

    final content = AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: _disabled ? 0.65 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: isOutlined
                ? Colors.transparent
                : isDestructive
                    ? dangerSoft
                    : null,
            gradient:
                isOutlined || isDestructive ? null : AppColors.indigoGradient,
            borderRadius: BorderRadius.circular(20),
            border: isOutlined
                ? Border.all(color: AppColors.primary, width: 1.4)
                : null,
            boxShadow: isOutlined || isDestructive
                ? null
                : [
                    AppColors.glowShadow,
                  ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _disabled ? null : onPressed,
            child: Container(
              height: 58,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOutlined ? AppColors.primary : Colors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: 22,
                            color: _foregroundColor,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.cardTitle.copyWith(
                              color: _foregroundColor,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    return isExpanded ? SizedBox(width: double.infinity, child: content) : content;
  }

  Color get _foregroundColor {
    if (isDestructive) {
      return AppColors.danger;
    }
    if (isOutlined) {
      return AppColors.primary;
    }
    return Colors.white;
  }
}
