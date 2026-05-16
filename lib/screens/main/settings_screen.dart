import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/section_title.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider?>();
    final settings = context.watch<SettingsProvider>();
    final alarm = context.read<AlarmProvider>();
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);

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
                Text(
                  'Settings',
                  style: AppTextStyles.headline.copyWith(color: textPrimary),
                ),
                const SizedBox(height: 26),
                _ProfileCard(auth: auth),
                const SizedBox(height: 28),
                const SectionTitle(title: 'Focus Preferences'),
                const SizedBox(height: 14),
                _SettingsSection(
                  children: [
                    _SettingsRow(
                      icon: Icons.timer_outlined,
                      iconColor: AppColors.primary,
                      iconBackground: AppColors.blueSoft,
                      title: 'Default Focus Duration',
                      subtitle: 'Set your default focus time',
                      trailing: _MenuTrailing<int>(
                        value: settings.defaultFocusDuration,
                        labelBuilder: (value) => '$value min',
                        values: const [25, 30, 45, 60, 90],
                        onSelected: settings.updateDefaultFocusDuration,
                      ),
                    ),
                    const _SettingsDivider(),
                    _SettingsRow(
                      icon: Icons.shield_rounded,
                      iconColor: AppColors.indigo,
                      iconBackground: AppColors.purpleSoft,
                      title: 'Strict Mode',
                      subtitle: 'Block distractions during focus sessions',
                      trailing: Switch(
                        value: settings.strictMode,
                        onChanged: (value) {
                          settings.updateStrictMode(value);
                        },
                      ),
                    ),
                    const _SettingsDivider(),
                    _SettingsRow(
                      icon: Icons.notifications_rounded,
                      iconColor: AppColors.warning,
                      iconBackground: AppColors.warningSoft,
                      title: 'Alarm Sound',
                      subtitle: 'Choose the sound for alarms',
                      trailing: _MenuTrailing<String>(
                        value: settings.alarmSound,
                        labelBuilder: (value) => value,
                        values: const ['Bright Morning', 'Gentle Chime'],
                        onSelected: (value) async {
                          await settings.updateAlarmSound(value);
                          await alarm.applySettings(soundName: value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const SectionTitle(title: 'Goals & Challenges'),
                const SizedBox(height: 14),
                _SettingsSection(
                  children: [
                    _SettingsRow(
                      icon: Icons.track_changes_rounded,
                      iconColor: AppColors.primary,
                      iconBackground: AppColors.blueSoft,
                      title: 'Daily Goal',
                      subtitle: 'Set your study target for each day',
                      trailing: _MenuTrailing<int>(
                        value: settings.dailyGoalMinutes,
                        labelBuilder: _formatGoalMinutes,
                        values: const [120, 180, 240, 300, 360],
                        onSelected: settings.updateDailyGoalMinutes,
                      ),
                    ),
                    const _SettingsDivider(),
                    _SettingsRow(
                      icon: Icons.emoji_events_rounded,
                      iconColor: AppColors.success,
                      iconBackground: AppColors.successSoft,
                      title: 'Challenge Difficulty',
                      subtitle: 'Adjust daily challenge difficulty',
                      trailing: _MenuTrailing<String>(
                        value: settings.challengeDifficulty,
                        labelBuilder: (value) => value,
                        values: const ['Easy', 'Medium', 'Hard'],
                        onSelected: (value) async {
                          await settings.updateChallengeDifficulty(value);
                          await alarm.applySettings(
                            challengeDifficulty: value,
                          );
                        },
                      ),
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
                      trailing: Switch(
                        value: settings.darkMode,
                        onChanged: (value) {
                          settings.updateDarkMode(value);
                        },
                      ),
                    ),
                  ],
                ),
                if (settings.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    settings.errorMessage!,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                _SettingsSection(
                  children: [
                    _SettingsRow(
                      icon: Icons.help_outline_rounded,
                      iconColor: textSecondary,
                      iconBackground: AppColors.cardSoftFor(context),
                      title: 'Help & Support',
                      subtitle: 'Get help and learn more',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: textSecondary,
                        size: 34,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  label: auth == null ? 'Login Disabled For Now' : 'Logout',
                  icon: Icons.logout_rounded,
                  isDestructive: true,
                  onPressed: auth == null ? null : () => auth.signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.auth});

  final AuthProvider? auth;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: auth == null ? null : () => _showProfileSheet(context, auth!),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardFor(context),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.borderFor(context)),
            boxShadow: AppColors.softShadowFor(context),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.blueSoftFor(context),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth?.displayName ?? 'Guest Student',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(
                        color: textPrimary,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      auth?.email ?? 'Auth will be enabled later',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showProfileSheet(
    BuildContext parentContext,
    AuthProvider auth,
  ) async {
    await showModalBottomSheet<void>(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSheet(auth: auth),
    );
  }
}

class _ProfileSheet extends StatefulWidget {
  const _ProfileSheet({required this.auth});

  final AuthProvider auth;

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  late final TextEditingController _nameController;
  bool _isSavingName = false;
  bool _isSendingReset = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.auth.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.cardFor(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppColors.softShadowFor(context),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.indigoGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.textPrimaryFor(context),
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Connected account information',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondaryFor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                AppTextField(
                  controller: _nameController,
                  label: 'Name',
                  hint: 'Your name',
                  prefixIcon: Icons.badge_rounded,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 18),
                _ProfileInfoRow(
                  icon: Icons.email_rounded,
                  title: 'Email',
                  value: widget.auth.email,
                ),
                const SizedBox(height: 12),
                _ProfileInfoRow(
                  icon: Icons.fingerprint_rounded,
                  title: 'User ID',
                  value: widget.auth.uid,
                ),
                if (widget.auth.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    widget.auth.errorMessage!,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                AppPrimaryButton(
                  label: 'Save Profile',
                  icon: Icons.save_rounded,
                  isLoading: _isSavingName,
                  onPressed: _isSavingName ? null : _saveProfile,
                ),
                const SizedBox(height: 12),
                AppPrimaryButton(
                  label: 'Send Password Reset',
                  icon: Icons.lock_reset_rounded,
                  isOutlined: true,
                  isLoading: _isSendingReset,
                  onPressed: _isSendingReset ? null : _sendPasswordReset,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isSavingName = true);
    final success = await widget.auth.updateDisplayName(_nameController.text);
    if (!mounted) {
      return;
    }
    setState(() => _isSavingName = false);

    if (success) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
    }
  }

  Future<void> _sendPasswordReset() async {
    setState(() => _isSendingReset = true);
    final success = await widget.auth.sendPasswordReset(widget.auth.email);
    if (!mounted) {
      return;
    }
    setState(() => _isSendingReset = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    }
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSoftFor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimaryFor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondaryFor(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        color: AppColors.cardFor(context),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppColors.softShadowFor(context),
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
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);

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
                Text(
                  title,
                  style: AppTextStyles.cardTitle.copyWith(color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.body.copyWith(color: textSecondary),
                ),
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
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimaryFor(context),
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondaryFor(context),
        ),
      ],
    );
  }
}

class _MenuTrailing<T> extends StatelessWidget {
  const _MenuTrailing({
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onSelected,
  });

  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final FutureOr<void> Function(T value) onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      initialValue: value,
      onSelected: (item) {
        onSelected(item);
      },
      color: AppColors.cardFor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      itemBuilder: (context) {
        return values
            .map(
              (item) => PopupMenuItem<T>(
                value: item,
                child: Text(
                  labelBuilder(item),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondaryFor(context),
                  ),
                ),
              ),
            )
            .toList(growable: false);
      },
      child: _ValueTrailing(value: labelBuilder(value)),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 90, right: 18),
      child: Divider(height: 1, color: AppColors.borderFor(context)),
    );
  }
}

String _formatGoalMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (hours == 0) {
    return '$remainingMinutes min';
  }
  if (remainingMinutes == 0) {
    return '${hours}h';
  }
  return '${hours}h ${remainingMinutes}m';
}
