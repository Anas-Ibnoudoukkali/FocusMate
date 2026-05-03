import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_gradient_card.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/section_title.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

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
                const _AlarmHeader(),
                const SizedBox(height: 28),
                const AppGradientCard(child: _AlarmHeroContent()),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [AppColors.softShadow],
                  ),
                  child: Column(
                    children: [
                      const _OptionRow(
                        icon: Icons.music_note_rounded,
                        title: 'Alarm Sound',
                        subtitle: 'Bright Morning',
                        iconColor: AppColors.indigo,
                        iconBackground: AppColors.purpleSoft,
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                          size: 32,
                        ),
                      ),
                      const _RowDivider(),
                      const _OptionRow(
                        icon: Icons.bar_chart_rounded,
                        title: 'Challenge Difficulty',
                        subtitle: 'Medium',
                        iconColor: AppColors.primary,
                        iconBackground: AppColors.blueSoft,
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                          size: 32,
                        ),
                      ),
                      const _RowDivider(),
                      _OptionRow(
                        icon: Icons.notifications_active_rounded,
                        title: 'Snooze',
                        subtitle: '5 minutes',
                        iconColor: AppColors.primary,
                        iconBackground: AppColors.blueSoft,
                        trailing: Switch(value: true, onChanged: (_) {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle(
                  title: 'Wake-up Challenge',
                  subtitle: 'Choose one or more challenges to turn off the alarm.',
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [AppColors.softShadow],
                  ),
                  child: const Column(
                    children: [
                      _ChallengeTile(
                        selected: true,
                        icon: Icons.calculate_rounded,
                        title: 'Solve 3 math questions',
                        subtitle: 'Answer 3 random math questions',
                        difficulty: 'Medium',
                        iconBackground: AppColors.indigo,
                      ),
                      _RowDivider(),
                      _ChallengeTile(
                        selected: true,
                        icon: Icons.lock_rounded,
                        title: 'Type verification code',
                        subtitle: 'Enter the shown code correctly',
                        difficulty: 'Easy',
                        iconBackground: AppColors.violet,
                      ),
                      _RowDivider(),
                      _ChallengeTile(
                        selected: false,
                        icon: Icons.apps_rounded,
                        title: 'Remember pattern',
                        subtitle: 'Repeat the pattern shown',
                        difficulty: 'Hard',
                        iconBackground: AppColors.success,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.14),
                        AppColors.indigo.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: AppColors.indigoGradient,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Challenge-based Wake-up',
                              style: AppTextStyles.cardTitle.copyWith(
                                color: AppColors.primary,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'The alarm stops after the wake-up challenge is completed.',
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                AppPrimaryButton(
                  label: 'Save Alarm',
                  icon: Icons.lock_open_rounded,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlarmHeroContent extends StatelessWidget {
  const _AlarmHeroContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: _AlarmTimeBlock(compact: true)),
                  Switch(value: true, onChanged: (_) {}),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: _AlarmIllustration(size: 92),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: _AlarmTimeBlock()),
            const SizedBox(width: 18),
            Column(
              children: [
                Switch(value: true, onChanged: (_) {}),
                const SizedBox(height: 22),
                _AlarmIllustration(size: 108),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _AlarmTimeBlock extends StatelessWidget {
  const _AlarmTimeBlock({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '07:00',
                style: AppTextStyles.display.copyWith(
                  color: Colors.white,
                  fontSize: compact ? 48 : 58,
                ),
              ),
              TextSpan(
                text: ' AM',
                style: AppTextStyles.title.copyWith(
                  color: Colors.white,
                  fontSize: compact ? 20 : 24,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _AlarmDays(),
        const SizedBox(height: 18),
        const _RepeatLabel(),
      ],
    );
  }
}

class _AlarmDays extends StatelessWidget {
  const _AlarmDays();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _DayChip(label: 'S', active: false),
        _DayChip(label: 'M', active: true),
        _DayChip(label: 'T', active: true),
        _DayChip(label: 'W', active: true),
        _DayChip(label: 'T', active: true),
        _DayChip(label: 'F', active: true),
        _DayChip(label: 'S', active: false),
      ],
    );
  }
}

class _RepeatLabel extends StatelessWidget {
  const _RepeatLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.repeat_rounded,
          color: Colors.white.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Repeats every Mon - Fri',
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _AlarmIllustration extends StatelessWidget {
  const _AlarmIllustration({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.alarm_rounded,
        color: Colors.white,
        size: size * 0.66,
      ),
    );
  }
}

class _AlarmHeader extends StatelessWidget {
  const _AlarmHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [AppColors.softShadow],
          ),
          child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Morning Alarm', style: AppTextStyles.headline),
              const SizedBox(height: 6),
              Text(
                'Set your alarm and choose a challenge.',
                style: AppTextStyles.body.copyWith(fontSize: 17),
              ),
            ],
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

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: active ? AppColors.primary : Colors.white,
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBackground,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackground;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  const _ChallengeTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.iconBackground,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final String difficulty;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: selected ? AppColors.indigoGradient : null,
              color: selected ? null : Colors.white,
              shape: BoxShape.circle,
              border: selected
                  ? null
                  : Border.all(color: AppColors.textMuted, width: 2),
            ),
            child: selected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 19)
                : null,
          ),
          const SizedBox(width: 14),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.blueSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(difficulty, style: AppTextStyles.label),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.drag_handle_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 86, right: 18),
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}
