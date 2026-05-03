import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/app_gradient_card.dart';
import '../../widgets/app_stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final firstName = auth.displayName.split(' ').first;

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
                              '2h 45m',
                              style: AppTextStyles.display.copyWith(
                                color: Colors.white,
                                fontSize: 52,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  '+ 35m vs yesterday',
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
                  value: '07:00 AM',
                  subtitle: 'Tomorrow',
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
                            const _ProgressBar(progress: 0.68),
                            const SizedBox(height: 14),
                            RichText(
                              text: TextSpan(
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 18,
                                ),
                                children: [
                                  TextSpan(
                                    text: '2h 45m',
                                    style: AppTextStyles.cardTitle.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const TextSpan(text: ' / 4h'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      const _ProgressRing(progress: 0.68, size: 116),
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
                      title: 'Dashboard',
                      subtitle: 'View insights',
                      icon: Icons.bar_chart_rounded,
                      iconColor: AppColors.success,
                      background: AppColors.successSoft,
                      onTap: () => context
                          .read<NavigationProvider>()
                          .setSection(AppSection.dashboard),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
              Text('of 4h goal', style: AppTextStyles.body.copyWith(fontSize: 12)),
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
