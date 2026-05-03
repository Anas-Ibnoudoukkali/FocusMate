import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_gradient_card.dart';
import '../../widgets/section_title.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
                const _DashboardHeader(),
                const SizedBox(height: 26),
                const AppGradientCard(child: _DashboardHeroContent()),
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 430) {
                      return const Column(
                        children: [
                          _GoalProgressCard(),
                          SizedBox(height: 16),
                          _CompletedTasksCard(),
                        ],
                      );
                    }

                    return const Row(
                      children: [
                        Expanded(child: _GoalProgressCard()),
                        SizedBox(width: 16),
                        Expanded(child: _CompletedTasksCard()),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [AppColors.softShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        title: 'Wake-up Stats',
                        subtitle: 'Your wake-up performance',
                        trailing: Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Expanded(
                            child: _WakeMetric(
                              icon: Icons.check_circle_outline_rounded,
                              value: '92%',
                              label: 'Alarm Success Rate',
                              caption: '+ 8% vs last week',
                              color: AppColors.success,
                              background: AppColors.successSoft,
                            ),
                          ),
                          _ThinDivider(),
                          Expanded(
                            child: _WakeMetric(
                              icon: Icons.alarm_on_rounded,
                              value: '14',
                              label: 'Alarms Completed',
                              caption: 'This Week',
                              color: AppColors.indigo,
                              background: AppColors.purpleSoft,
                            ),
                          ),
                          _ThinDivider(),
                          Expanded(
                            child: _WakeMetric(
                              icon: Icons.wb_twilight_rounded,
                              value: '7:12 AM',
                              label: 'Average Wake-up Time',
                              caption: '- 12m vs last week',
                              color: AppColors.warning,
                              background: AppColors.warningSoft,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [AppColors.softShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Weekly Study Time',
                              style: AppTextStyles.cardTitle,
                            ),
                          ),
                          const _Legend(color: AppColors.primary, label: 'This Week'),
                          const SizedBox(width: 12),
                          const _Legend(color: AppColors.border, label: 'Last Week'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const _WeeklyChart(),
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

class _DashboardHeroContent extends StatelessWidget {
  const _DashboardHeroContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 430) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroFocusMetric(),
              Container(
                height: 1,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 22),
                color: Colors.white.withValues(alpha: 0.22),
              ),
              const _HeroStreakMetric(),
            ],
          );
        }

        return Row(
          children: [
            const Expanded(child: _HeroFocusMetric()),
            Container(
              width: 1,
              height: 118,
              color: Colors.white.withValues(alpha: 0.22),
            ),
            const SizedBox(width: 24),
            const Expanded(child: _HeroStreakMetric()),
          ],
        );
      },
    );
  }
}

class _HeroFocusMetric extends StatelessWidget {
  const _HeroFocusMetric();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Total Focus Time',
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.info_outline_rounded,
              color: Colors.white.withValues(alpha: 0.76),
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '23h 40m',
          style: AppTextStyles.display.copyWith(
            color: Colors.white,
            fontSize: 48,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '+ 3h 25m vs last week',
          style: AppTextStyles.body.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _HeroStreakMetric extends StatelessWidget {
  const _HeroStreakMetric();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Streak',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '12',
                      style: AppTextStyles.display.copyWith(
                        color: Colors.white,
                        fontSize: 48,
                      ),
                    ),
                    TextSpan(
                      text: ' days',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Keep it going!',
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_fire_department_rounded,
            color: Colors.white,
            size: 54,
          ),
        ),
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard', style: AppTextStyles.headline),
              const SizedBox(height: 8),
              Text(
                'Track your progress and stay motivated.',
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
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: const Icon(Icons.person_rounded, color: AppColors.textPrimary),
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard();

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
          Text('Goal Progress', style: AppTextStyles.cardTitle),
          const SizedBox(height: 6),
          Text('Stay consistent. You\'ve got this!', style: AppTextStyles.body),
          const SizedBox(height: 24),
          Row(
            children: [
              const _Ring(progress: 0.68),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2h 45m',
                      style: AppTextStyles.title.copyWith(fontSize: 24),
                    ),
                    Text('/ 4h', style: AppTextStyles.body),
                    const SizedBox(height: 8),
                    Text('Today', style: AppTextStyles.body),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedTasksCard extends StatelessWidget {
  const _CompletedTasksCard();

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
          Row(
            children: [
              Expanded(child: Text('Completed Tasks', style: AppTextStyles.cardTitle)),
              Text('Today', style: AppTextStyles.body),
              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 18),
          const _CompletedRow(
            icon: Icons.check_rounded,
            label: 'Focus Sessions',
            value: '3',
            color: AppColors.primary,
            background: AppColors.blueSoft,
          ),
          const SizedBox(height: 10),
          const _CompletedRow(
            icon: Icons.notifications_rounded,
            label: 'Alarms Completed',
            value: '2',
            color: AppColors.warning,
            background: AppColors.warningSoft,
          ),
          const SizedBox(height: 10),
          const _CompletedRow(
            icon: Icons.task_alt_rounded,
            label: 'Tasks Completed',
            value: '5',
            color: AppColors.success,
            background: AppColors.successSoft,
          ),
          const SizedBox(height: 18),
          const Divider(color: AppColors.border),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Total Completed',
                style: AppTextStyles.label.copyWith(fontSize: 16),
              ),
              const Spacer(),
              Text(
                '10',
                style: AppTextStyles.label.copyWith(fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.blueSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: AppTextStyles.title.copyWith(fontSize: 24),
              ),
              Text(
                'of 4h',
                style: AppTextStyles.body.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedRow extends StatelessWidget {
  const _CompletedRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: background, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _WakeMetric extends StatelessWidget {
  const _WakeMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.caption,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String value;
  final String label;
  final String caption;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          textAlign: TextAlign.center,
          style: AppTextStyles.title.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: color, fontSize: 12),
        ),
      ],
    );
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 116,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: AppColors.border,
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.body.copyWith(fontSize: 12)),
      ],
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart();

  static const List<_BarData> _data = [
    _BarData('Mon', 0.55, 0.46, '3h 20m'),
    _BarData('Tue', 0.70, 0.52, '4h 15m'),
    _BarData('Wed', 0.46, 0.38, '2h 45m'),
    _BarData('Thu', 0.86, 0.72, '5h 10m'),
    _BarData('Fri', 0.62, 0.50, '3h 50m'),
    _BarData('Sat', 0.35, 0.30, '2h 05m'),
    _BarData('Sun', 0.42, 0.34, '2h 15m'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _data.map((bar) {
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  bar.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 112,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Bar(heightFactor: bar.thisWeek, color: AppColors.primary),
                      const SizedBox(width: 4),
                      _Bar(heightFactor: bar.lastWeek, color: AppColors.border),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  bar.day,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.heightFactor,
    required this.color,
  });

  final double heightFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: heightFactor,
      child: Container(
        width: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _BarData {
  const _BarData(this.day, this.thisWeek, this.lastWeek, this.label);

  final String day;
  final double thisWeek;
  final double lastWeek;
  final String label;
}
