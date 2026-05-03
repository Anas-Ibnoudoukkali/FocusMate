import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/app_gradient_card.dart';
import '../../widgets/section_title.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

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
                const _PlannerHeader(),
                const SizedBox(height: 28),
                AppGradientCard(
                  title: 'Daily Goal',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Edit Goal',
                          style: AppTextStyles.label.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: _GoalMetric(
                          icon: Icons.access_time_filled_rounded,
                          label: 'Study Time',
                          value: '4h 00m',
                          caption: 'of 4h goal',
                        ),
                      ),
                      _GoalDivider(),
                      Expanded(
                        child: _GoalMetric(
                          icon: Icons.track_changes_rounded,
                          label: 'Tasks',
                          value: '4',
                          caption: 'of 4 tasks',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SectionTitle(
                  title: 'Today\'s Plan',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blueSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '4 tasks',
                          style: AppTextStyles.label,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Sort',
                        style: AppTextStyles.label.copyWith(fontSize: 16),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [AppColors.softShadow],
                  ),
                  child: Column(
                    children: [
                      const _TaskTile(
                        title: 'Review Chapter 5 - Cell Structure',
                        subject: 'Biology',
                        minutes: 45,
                        completed: true,
                        color: AppColors.success,
                      ),
                      const _TaskDivider(),
                      _TaskTile(
                        title: 'Solve Calculus Problem Set',
                        subject: 'Mathematics',
                        minutes: 60,
                        completed: false,
                        color: AppColors.primary,
                        primaryAction: true,
                        onStart: () => context
                            .read<NavigationProvider>()
                            .setSection(AppSection.focus),
                      ),
                      const _TaskDivider(),
                      _TaskTile(
                        title: 'Read: The Psychology of Learning',
                        subject: 'Psychology',
                        minutes: 30,
                        completed: false,
                        color: AppColors.violet,
                        onStart: () => context
                            .read<NavigationProvider>()
                            .setSection(AppSection.focus),
                      ),
                      const _TaskDivider(),
                      const _TaskTile(
                        title: 'Flashcards - Spanish Vocabulary',
                        subject: 'Spanish',
                        minutes: 25,
                        completed: true,
                        color: AppColors.warning,
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_rounded),
                        label: Text(
                          'Add Task',
                          style: AppTextStyles.label.copyWith(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Progress Today', style: AppTextStyles.cardTitle),
                            const SizedBox(height: 8),
                            Text('Great job! Keep going.', style: AppTextStyles.body),
                          ],
                        ),
                      ),
                      const _MiniProgressRing(progress: 0.5),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('2 of 4 tasks completed', style: AppTextStyles.body),
                            const SizedBox(height: 10),
                            const _ProgressBar(progress: 0.5),
                            const SizedBox(height: 10),
                            Text('2 tasks remaining', style: AppTextStyles.body),
                          ],
                        ),
                      ),
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

class _PlannerHeader extends StatelessWidget {
  const _PlannerHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.indigoGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [AppColors.glowShadow],
          ),
          child: const Icon(Icons.calendar_month_rounded, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Study Planner', style: AppTextStyles.headline),
              const SizedBox(height: 6),
              Text(
                'Plan your day. Stay consistent.',
                style: AppTextStyles.body.copyWith(fontSize: 18),
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

class _GoalMetric extends StatelessWidget {
  const _GoalMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.title.copyWith(color: Colors.white, fontSize: 32),
        ),
        const SizedBox(height: 4),
        Text(
          caption,
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: 1,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }
}

class _GoalDivider extends StatelessWidget {
  const _GoalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      color: Colors.white.withValues(alpha: 0.24),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.title,
    required this.subject,
    required this.minutes,
    required this.completed,
    required this.color,
    this.primaryAction = false,
    this.onStart,
  });

  final String title;
  final String subject;
  final int minutes;
  final bool completed;
  final Color color;
  final bool primaryAction;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: completed ? AppColors.indigoGradient : null,
              color: completed ? null : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: completed
                  ? null
                  : Border.all(color: AppColors.textMuted, width: 1.4),
            ),
            child: completed
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cardTitle.copyWith(
                    decoration:
                        completed ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _SubjectChip(label: subject, color: color),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text('$minutes min', style: AppTextStyles.body),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!completed) ...[
            const SizedBox(width: 12),
            _StartFocusButton(
              primary: primaryAction,
              onTap: onStart,
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskDivider extends StatelessWidget {
  const _TaskDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 68, right: 18),
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: color),
      ),
    );
  }
}

class _StartFocusButton extends StatelessWidget {
  const _StartFocusButton({
    required this.primary,
    this.onTap,
  });

  final bool primary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: primary ? AppColors.indigoGradient : null,
            color: primary ? null : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: primary
                ? null
                : Border.all(color: AppColors.primary, width: 1.3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow_rounded,
                color: primary ? Colors.white : AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                'Start',
                style: AppTextStyles.label.copyWith(
                  color: primary ? Colors.white : AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniProgressRing extends StatelessWidget {
  const _MiniProgressRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 82,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 82,
            height: 82,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.blueSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: AppTextStyles.cardTitle,
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: 10,
        value: progress,
        backgroundColor: AppColors.blueSoft,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}
