import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/section_title.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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
                Text('Settings', style: AppTextStyles.headline),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [AppColors.softShadow],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.blueSoft,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.textPrimary,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.title.copyWith(fontSize: 22),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              auth.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body.copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                        size: 34,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const SectionTitle(title: 'Focus Preferences'),
                const SizedBox(height: 14),
                _SettingsSection(
                  children: [
                    const _SettingsRow(
                      icon: Icons.timer_outlined,
                      iconColor: AppColors.primary,
                      iconBackground: AppColors.blueSoft,
                      title: 'Default Focus Duration',
                      subtitle: 'Set your default focus time',
                      trailing: _ValueTrailing(value: '45 min'),
                    ),
                    const _SettingsDivider(),
                    _SettingsRow(
                      icon: Icons.shield_rounded,
                      iconColor: AppColors.indigo,
                      iconBackground: AppColors.purpleSoft,
                      title: 'Strict Mode',
                      subtitle: 'Block distractions during focus sessions',
                      trailing: Switch(value: true, onChanged: (_) {}),
                    ),
                    const _SettingsDivider(),
                    const _SettingsRow(
                      icon: Icons.notifications_rounded,
                      iconColor: AppColors.warning,
                      iconBackground: AppColors.warningSoft,
                      title: 'Alarm Sound',
                      subtitle: 'Choose the sound for alarms',
                      trailing: _ValueTrailing(value: 'Gentle Chime'),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const SectionTitle(title: 'Goals & Challenges'),
                const SizedBox(height: 14),
                const _SettingsSection(
                  children: [
                    _SettingsRow(
                      icon: Icons.emoji_events_rounded,
                      iconColor: AppColors.success,
                      iconBackground: AppColors.successSoft,
                      title: 'Challenge Difficulty',
                      subtitle: 'Adjust daily challenge difficulty',
                      trailing: _ValueTrailing(value: 'Medium'),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const SectionTitle(title: 'Notifications & Appearance'),
                const SizedBox(height: 14),
                _SettingsSection(
                  children: [
                    _SettingsRow(
                      icon: Icons.notifications_active_rounded,
                      iconColor: AppColors.primary,
                      iconBackground: AppColors.blueSoft,
                      title: 'Notifications',
                      subtitle: 'Receive reminders and updates',
                      trailing: Switch(value: true, onChanged: (_) {}),
                    ),
                    const _SettingsDivider(),
                    _SettingsRow(
                      icon: Icons.dark_mode_rounded,
                      iconColor: AppColors.indigo,
                      iconBackground: AppColors.purpleSoft,
                      title: 'Dark Mode',
                      subtitle: 'Use a dark theme across the app',
                      trailing: Switch(value: false, onChanged: (_) {}),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const _SettingsSection(
                  children: [
                    _SettingsRow(
                      icon: Icons.help_outline_rounded,
                      iconColor: AppColors.textSecondary,
                      iconBackground: AppColors.cardSoft,
                      title: 'Help & Support',
                      subtitle: 'Get help and learn more',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                        size: 34,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  label: 'Logout',
                  icon: Icons.logout_rounded,
                  isDestructive: true,
                  onPressed: () => context.read<AuthProvider>().signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
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
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _ValueTrailing extends StatelessWidget {
  const _ValueTrailing({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 96),
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: AppTextStyles.label.copyWith(fontSize: 16),
          ),
        ),
        const SizedBox(width: 6),
        const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 90, right: 18),
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}
