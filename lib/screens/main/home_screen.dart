import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/focus_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/app_gradient_card.dart';
import '../../widgets/app_stat_card.dart';
import '../../widgets/section_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider?>();
    final alarm = context.watch<AlarmProvider>();
    final focus = context.watch<FocusProvider>();
    final settings = context.watch<SettingsProvider>();
    final tasks = context.watch<TaskProvider>();
    final firstName = (auth?.displayName ?? 'Student').split(' ').first;
    final dailyGoalProgress = focus.dailyGoalProgress;

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
                Row(
                  children: [
                    const _ShieldLogo(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        AppConstants.appName,
                        style: AppTextStyles.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const _UserAvatar(),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Good morning, $firstName!',
                  style: AppTextStyles.title.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay focused. Achieve more.',
                  style: AppTextStyles.body.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 26),
                AppGradientCard(
                  title: 'Today\'s Focus Time',
                  trailing: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white.withValues(alpha: 0.76),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatSecondsAsHours(focus.todayFocusSeconds),
                              style: AppTextStyles.display.copyWith(
                                color: Colors.white,
                                fontSize: 52,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  '${focus.currentStreak} day streak',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.trending_up_rounded,
                                  color: Color(0xFF66F2B5),
                                  size: 22,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.hourglass_bottom_rounded,
                          size: 62,
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppStatCard(
                  title: 'Next Alarm',
                  value: alarm.nextAlarmLabel,
                  subtitle: alarm.nextAlarmSubtitle,
                  icon: Icons.notifications_active_rounded,
                  iconColor: AppColors.indigo,
                  iconBackground: AppColors.purpleSoft,
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 34,
                  ),
                  onTap: () => context
                      .read<NavigationProvider>()
                      .setSection(AppSection.alarm),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [AppColors.softShadow],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Goal Progress',
                              style: AppTextStyles.cardTitle,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Stay consistent. You\'ve got this!',
                              style: AppTextStyles.body,
                            ),
                            const SizedBox(height: 26),
                            _ProgressBar(progress: dailyGoalProgress),
                            const SizedBox(height: 14),
                            RichText(
                              text: TextSpan(
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 18,
                                ),
                                children: [
                                  TextSpan(
                                    text: _formatSecondsAsHours(
                                      focus.todayFocusSeconds,
                                    ),
                                    style: AppTextStyles.cardTitle.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 20,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' / ${_formatMinutes(settings.dailyGoalMinutes)}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      _ProgressRing(progress: dailyGoalProgress, size: 116),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.12,
                  children: [
                    _QuickActionCard(
                      title: 'Planner',
                      subtitle: 'Plan your day',
                      icon: Icons.calendar_month_rounded,
                      iconColor: AppColors.primary,
                      background: AppColors.blueSoft,
                      onTap: () => context
                          .read<NavigationProvider>()
                          .setSection(AppSection.planner),
                    ),
                    _QuickActionCard(
                      title: 'Start Focus',
                      subtitle: 'Begin a session',
                      icon: Icons.play_arrow_rounded,
                      iconColor: Colors.white,
                      background: AppColors.indigo,
                      onTap: () => context
                          .read<NavigationProvider>()
                          .setSection(AppSection.focus),
                    ),
                    _QuickActionCard(
                      title: 'Set Alarm',
                      subtitle: 'Add reminder',
                      icon: Icons.notifications_rounded,
                      iconColor: AppColors.warning,
                      background: AppColors.warningSoft,
                      onTap: () => context
                          .read<NavigationProvider>()
                          .setSection(AppSection.alarm),
                    ),
                    _QuickActionCard(
                      title: 'Test Alarm',
                      subtitle: 'Trigger wake-up',
                      icon: Icons.bar_chart_rounded,
                      iconColor: AppColors.success,
                      background: AppColors.successSoft,
                      onTap: alarm.triggerAlarmManually,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SectionTitle(
                  title: 'Stats',
                  subtitle: 'Combined from your planner and focus work.',
                  trailing: Text(
                    'Today',
                    style: AppTextStyles.label.copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                _StatsOverview(
                  tasks: tasks,
                  focus: focus,
                  alarm: alarm,
                ),
                const SizedBox(height: 18),
                _WeeklyStudyCard(values: focus.weeklyFocusSeconds),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsOverview extends StatelessWidget {
  const _StatsOverview({
    required this.tasks,
    required this.focus,
    required this.alarm,
  });

  final TaskProvider tasks;
  final FocusProvider focus;
  final AlarmProvider alarm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.softShadow],
      ),
      child: Wrap(
        runSpacing: 18,
        children: [
          _MetricSlot(
            child: _HomeStatMetric(
              icon: Icons.schedule_rounded,
              value: _formatSecondsAsHours(focus.totalFocusSeconds),
              label: 'Total Focus',
              color: AppColors.primary,
              background: AppColors.blueSoft,
            ),
          ),
          _MetricSlot(
            child: _HomeStatMetric(
              icon: Icons.today_rounded,
              value: _formatSecondsAsHours(focus.todayFocusSeconds),
              label: 'Today',
              color: AppColors.indigo,
              background: AppColors.purpleSoft,
            ),
          ),
          _MetricSlot(
            child: _HomeStatMetric(
              icon: Icons.task_alt_rounded,
              value: '${tasks.completedTasks}',
              label: 'Tasks Done',
              color: AppColors.success,
              background: AppColors.successSoft,
            ),
          ),
          _MetricSlot(
            child: _HomeStatMetric(
              icon: Icons.local_fire_department_rounded,
              value: '${focus.currentStreak}d',
              label: 'Streak',
              color: AppColors.warning,
              background: AppColors.warningSoft,
            ),
          ),
          _MetricSlot(
            child: _HomeStatMetric(
              icon: Icons.notifications_active_rounded,
              value: alarm.alarmSuccessLabel,
              label: 'Alarm Success',
              color: AppColors.indigo,
              background: AppColors.blueSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSlot extends StatelessWidget {
  const _MetricSlot({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 150, child: child);
  }
}

class _HomeStatMetric extends StatelessWidget {
  const _HomeStatMetric({
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
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.title.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _WeeklyStudyCard extends StatelessWidget {
  const _WeeklyStudyCard({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Study Time', style: AppTextStyles.cardTitle),
          const SizedBox(height: 18),
          _WeeklyBars(values: values),
        ],
      ),
    );
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.values});

  static const List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<int>(0, (max, value) => value > max ? value : max);

    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_days.length, (index) {
          final seconds = index < values.length ? values[index] : 0;
          final heightFactor = maxValue == 0
              ? 0.08
              : (seconds / maxValue).clamp(0.08, 1.0).toDouble();
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  seconds == 0 ? '0m' : _formatCompactSeconds(seconds),
                  style: AppTextStyles.body.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: heightFactor,
                      child: Container(
                        width: 16,
                        decoration: BoxDecoration(
                          gradient: AppColors.indigoGradient,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _days[index],
                  style: AppTextStyles.body.copyWith(fontSize: 12),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ShieldLogo extends StatelessWidget {
  const _ShieldLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        gradient: AppColors.indigoGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.glowShadow],
      ),
      child: const Icon(Icons.shield_rounded, color: Colors.white, size: 38),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [AppColors.softShadow],
      ),
      child: const Icon(Icons.person_rounded, color: AppColors.textPrimary),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.size,
  });

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
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
              value: progress,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.blueSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: AppTextStyles.title.copyWith(fontSize: 26),
              ),
              Text(
                'daily goal',
                style: AppTextStyles.body.copyWith(fontSize: 12),
              ),
            ],
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

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [AppColors.softShadow],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (hours == 0) {
    return '${remainingMinutes}m';
  }
  return '${hours}h ${remainingMinutes.toString().padLeft(2, '0')}m';
}

String _formatSecondsAsHours(int seconds) {
  final minutes = seconds ~/ 60;
  return _formatMinutes(minutes);
}

String _formatCompactSeconds(int seconds) {
  final minutes = seconds ~/ 60;
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (hours == 0) {
    return '${remainingMinutes}m';
  }
  if (remainingMinutes == 0) {
    return '${hours}h';
  }
  return '${hours}h ${remainingMinutes}m';
}
