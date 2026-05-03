import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 126),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxMobileContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FocusHeader(),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [AppColors.softShadow],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.blueSoft,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.code_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Programming', style: AppTextStyles.cardTitle),
                            const SizedBox(height: 6),
                            Text(
                              'Finish React components',
                              style: AppTextStyles.body.copyWith(fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.track_changes_rounded, color: AppColors.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [AppColors.softShadow],
                  ),
                  child: Column(
                    children: [
                      const Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _Pill(
                            icon: Icons.timer_outlined,
                            label: 'Pomodoro',
                            color: AppColors.primary,
                            background: AppColors.blueSoft,
                          ),
                          _Pill(
                            icon: Icons.shield_rounded,
                            label: 'Strict Mode Active',
                            color: AppColors.success,
                            background: AppColors.successSoft,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const _TimerRing(),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [AppColors.softShadow],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final details = Row(
                        children: [
                          Container(
                            width: 62,
                            height: 62,
                            decoration: const BoxDecoration(
                              color: AppColors.dangerSoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.do_not_disturb_alt_rounded,
                              color: AppColors.danger,
                              size: 34,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Distractions', style: AppTextStyles.body),
                                Text('0', style: AppTextStyles.title),
                                Text(
                                  'Keep it up! You\'re doing great.',
                                  style: AppTextStyles.body,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );

                      if (constraints.maxWidth < 360) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            details,
                            const SizedBox(height: 16),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: _SoftButton(
                                label: 'I got distracted',
                                icon: Icons.close_rounded,
                                color: AppColors.danger,
                                background: AppColors.dangerSoft,
                              ),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: details),
                          const SizedBox(width: 12),
                          const _SoftButton(
                            label: 'I got distracted',
                            icon: Icons.close_rounded,
                            color: AppColors.danger,
                            background: AppColors.dangerSoft,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [AppColors.softShadow],
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: _ControlButton(
                          label: 'Pause',
                          icon: Icons.pause_rounded,
                          color: AppColors.primary,
                          background: AppColors.blueSoft,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _ControlButton(
                          label: 'End Session',
                          icon: Icons.stop_rounded,
                          color: AppColors.danger,
                          background: AppColors.dangerSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [AppColors.softShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Session Review (Live)',
                                  style: AppTextStyles.cardTitle,
                                ),
                                const SizedBox(height: 6),
                                Text('You\'re on track!', style: AppTextStyles.body),
                              ],
                            ),
                          ),
                          const _Pill(
                            icon: Icons.trending_up_rounded,
                            label: 'Great focus',
                            color: AppColors.success,
                            background: AppColors.successSoft,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Row(
                        children: [
                          Expanded(
                            child: _ReviewMetric(
                              icon: Icons.do_not_disturb_alt_rounded,
                              value: '0',
                              label: 'Distractions',
                              color: AppColors.danger,
                              background: AppColors.dangerSoft,
                            ),
                          ),
                          _VerticalDivider(),
                          Expanded(
                            child: _ReviewMetric(
                              icon: Icons.output_rounded,
                              value: '0',
                              label: 'Exit Attempts',
                              color: AppColors.warning,
                              background: AppColors.warningSoft,
                            ),
                          ),
                          _VerticalDivider(),
                          Expanded(
                            child: _ReviewMetric(
                              icon: Icons.check_circle_outline_rounded,
                              value: '56%',
                              label: 'Goal Progress',
                              color: AppColors.success,
                              background: AppColors.successSoft,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: const LinearProgressIndicator(
                          minHeight: 10,
                          value: 0.56,
                          backgroundColor: AppColors.blueSoft,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Keep going - you\'ve got this!', style: AppTextStyles.body),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusHeader extends StatelessWidget {
  const _FocusHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.indigoGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [AppColors.glowShadow],
          ),
          child: const Icon(Icons.shield_rounded, color: Colors.white, size: 42),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Focus Session',
            style: AppTextStyles.headline,
            maxLines: 2,
          ),
        ),
        const _Avatar(),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: const Icon(Icons.person_rounded, color: AppColors.textPrimary),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _TimerRing extends StatelessWidget {
  const _TimerRing();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < 264 ? constraints.maxWidth : 264.0;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: 0.74,
                  strokeWidth: 14,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.blueSoft,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Focus Time',
                    style: AppTextStyles.body.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '18:42',
                    style: AppTextStyles.display.copyWith(fontSize: 52),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'remaining',
                    style: AppTextStyles.body.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.blueSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('25m session', style: AppTextStyles.label),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SoftButton extends StatelessWidget {
  const _SoftButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.cardTitle.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewMetric extends StatelessWidget {
  const _ReviewMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.title.copyWith(fontSize: 24)),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.border,
    );
  }
}
