import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/alarm_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_gradient_card.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/section_title.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  TimeOfDay? _selectedTime;
  bool? _enabled;
  String? _difficulty;
  String? _soundName;
  List<String>? _repeatingDays;
  Set<DateTime>? _selectedDates;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final alarmProvider = context.watch<AlarmProvider>();
    final settings = context.watch<SettingsProvider>();
    final alarm = alarmProvider.alarm;
    final time = _selectedTime ??
        TimeOfDay(hour: alarm?.hour ?? 7, minute: alarm?.minute ?? 0);
    final enabled = _enabled ?? alarm?.enabled ?? true;
    final difficulty =
        _difficulty ?? alarm?.challengeDifficulty ?? settings.challengeDifficulty;
    final soundName = _soundName ?? alarm?.soundName ?? settings.alarmSound;
    final repeatingDays = _repeatingDays ??
        alarm?.repeatingDays ??
        const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final selectedDates = _selectedDates ??
        (alarm?.selectedDates.map(_normalizeDate).toSet() ?? <DateTime>{});
    final nextAlarmDate = _nextAlarmDate(time, repeatingDays, selectedDates);

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
                AppGradientCard(
                  child: _AlarmHeroContent(
                    time: time,
                    nextAlarmDate: nextAlarmDate,
                    enabled: enabled,
                    repeatingDays: repeatingDays,
                    onTimeTap: _pickTime,
                    onEnabledChanged: (value) {
                      setState(() => _enabled = value);
                    },
                    onDayToggled: _toggleRepeatingDay,
                  ),
                ),
                const SizedBox(height: 20),
                _AlarmCalendarCard(
                  focusedDay: _focusedDay,
                  selectedDates: selectedDates,
                  onDaySelected: _toggleSelectedDate,
                  onPageChanged: (focusedDay) {
                    setState(() => _focusedDay = focusedDay);
                  },
                ),
                const SizedBox(height: 20),
                _SettingsCard(
                  soundName: soundName,
                  difficulty: difficulty,
                  onSoundChanged: (value) {
                    setState(() => _soundName = value);
                  },
                  onDifficultyChanged: (value) {
                    setState(() => _difficulty = value);
                  },
                ),
                const SizedBox(height: 24),
                const SectionTitle(
                  title: 'Wake-up Challenge',
                  subtitle: 'Solve the challenge to turn off the alarm.',
                ),
                const SizedBox(height: 14),
                const _ChallengeCard(),
                const SizedBox(height: 20),
                const _ChallengeInfoCard(),
                const SizedBox(height: 22),
                AppPrimaryButton(
                  label: 'Save Alarm',
                  icon: Icons.save_rounded,
                  isLoading: alarmProvider.isSaving,
                  onPressed: () => _saveAlarm(
                    alarmProvider,
                    time,
                    enabled,
                    soundName,
                    difficulty,
                    repeatingDays,
                    selectedDates.toList(),
                  ),
                ),
                const SizedBox(height: 14),
                AppPrimaryButton(
                  label: 'Test Alarm',
                  icon: Icons.notifications_active_rounded,
                  isOutlined: true,
                  onPressed: alarmProvider.triggerAlarmManually,
                ),
                if (alarmProvider.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    alarmProvider.errorMessage!,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final currentAlarm = context.read<AlarmProvider>().alarm;
    final initialTime = _selectedTime ??
        TimeOfDay(
          hour: currentAlarm?.hour ?? 7,
          minute: currentAlarm?.minute ?? 0,
        );
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  Future<void> _saveAlarm(
    AlarmProvider alarmProvider,
    TimeOfDay time,
    bool enabled,
    String soundName,
    String difficulty,
    List<String> repeatingDays,
    List<DateTime> selectedDates,
  ) {
    return alarmProvider.saveAlarm(
      hour: time.hour,
      minute: time.minute,
      enabled: enabled,
      soundName: soundName,
      challengeDifficulty: difficulty,
      repeatingDays: repeatingDays,
      selectedDates: selectedDates,
    );
  }

  void _toggleRepeatingDay(String day) {
    final alarm = context.read<AlarmProvider>().alarm;
    final currentDays = List<String>.from(
      _repeatingDays ??
          alarm?.repeatingDays ??
          const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    );

    setState(() {
      if (currentDays.contains(day)) {
        if (currentDays.length == 1) {
          return;
        }
        currentDays.remove(day);
      } else {
        currentDays.add(day);
      }
      _repeatingDays = currentDays;
    });
  }

  void _toggleSelectedDate(DateTime selectedDay) {
    final normalizedDay = _normalizeDate(selectedDay);
    final alarm = context.read<AlarmProvider>().alarm;
    final currentDates = Set<DateTime>.from(
      _selectedDates ??
          (alarm?.selectedDates.map(_normalizeDate).toSet() ?? <DateTime>{}),
    );

    setState(() {
      if (currentDates.contains(normalizedDay)) {
        currentDates.remove(normalizedDay);
      } else {
        currentDates.add(normalizedDay);
      }
      _selectedDates = currentDates;
      _focusedDay = normalizedDay;
    });
  }

  DateTime _nextAlarmDate(
    TimeOfDay time,
    List<String> repeatingDays,
    Set<DateTime> selectedDates,
  ) {
    final now = DateTime.now();
    final upcomingSelectedDates = selectedDates
        .map(_normalizeDate)
        .map((date) => DateTime(date.year, date.month, date.day, time.hour,
            time.minute))
        .where((scheduled) => scheduled.isAfter(now))
        .toList()
      ..sort();

    if (upcomingSelectedDates.isNotEmpty) {
      return upcomingSelectedDates.first;
    }

    final selectedDays = repeatingDays.isEmpty
        ? const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        : repeatingDays;

    for (var dayOffset = 0; dayOffset <= 7; dayOffset++) {
      final candidateDay = now.add(Duration(days: dayOffset));
      final candidate = DateTime(
        candidateDay.year,
        candidateDay.month,
        candidateDay.day,
        time.hour,
        time.minute,
      );

      if (!selectedDays.contains(_weekdayKey(candidate.weekday))) {
        continue;
      }

      if (candidate.isAfter(now)) {
        return candidate;
      }
    }

    return now.add(const Duration(days: 1));
  }

  String _weekdayKey(int weekday) {
    const keys = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return keys[weekday - 1];
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class _AlarmHeroContent extends StatelessWidget {
  const _AlarmHeroContent({
    required this.time,
    required this.nextAlarmDate,
    required this.enabled,
    required this.repeatingDays,
    required this.onTimeTap,
    required this.onEnabledChanged,
    required this.onDayToggled,
  });

  final TimeOfDay time;
  final DateTime nextAlarmDate;
  final bool enabled;
  final List<String> repeatingDays;
  final VoidCallback onTimeTap;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<String> onDayToggled;

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
                  Expanded(
                    child: _AlarmTimeBlock(
                      time: time,
                      nextAlarmDate: nextAlarmDate,
                      compact: true,
                      repeatingDays: repeatingDays,
                      onTimeTap: onTimeTap,
                      onDayToggled: onDayToggled,
                    ),
                  ),
                  Switch(value: enabled, onChanged: onEnabledChanged),
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
            Expanded(
              child: _AlarmTimeBlock(
                time: time,
                nextAlarmDate: nextAlarmDate,
                repeatingDays: repeatingDays,
                onTimeTap: onTimeTap,
                onDayToggled: onDayToggled,
              ),
            ),
            const SizedBox(width: 18),
            Column(
              children: [
                Switch(value: enabled, onChanged: onEnabledChanged),
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
  const _AlarmTimeBlock({
    required this.time,
    required this.nextAlarmDate,
    required this.repeatingDays,
    required this.onTimeTap,
    required this.onDayToggled,
    this.compact = false,
  });

  final TimeOfDay time;
  final DateTime nextAlarmDate;
  final List<String> repeatingDays;
  final VoidCallback onTimeTap;
  final ValueChanged<String> onDayToggled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final nextAlarmLabel = _formatNextAlarm(context, nextAlarmDate);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTimeTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${hour.toString().padLeft(2, '0')}:'
                      '${time.minute.toString().padLeft(2, '0')}',
                  style: AppTextStyles.display.copyWith(
                    color: Colors.white,
                    fontSize: compact ? 48 : 58,
                  ),
                ),
                TextSpan(
                  text: ' $period',
                  style: AppTextStyles.title.copyWith(
                    color: Colors.white,
                    fontSize: compact ? 20 : 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _AlarmDays(
            selectedDays: repeatingDays,
            onDayToggled: onDayToggled,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white.withValues(alpha: 0.95),
                  size: 19,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    nextAlarmLabel,
                    style: AppTextStyles.label.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                Icons.touch_app_rounded,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Tap time to edit',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNextAlarm(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final alarmDay = DateTime(date.year, date.month, date.day);
    final dayDifference = alarmDay.difference(today).inDays;
    final dayLabel = switch (dayDifference) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ => _weekdayName(date.weekday),
    };
    final dateLabel = '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} ${date.year}';
    final timeLabel =
        TimeOfDay(hour: date.hour, minute: date.minute).format(context);

    return 'Next: $dayLabel, $dateLabel at $timeLabel';
  }

  String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[weekday - 1];
  }

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}

class _AlarmCalendarCard extends StatelessWidget {
  const _AlarmCalendarCard({
    required this.focusedDay,
    required this.selectedDates,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final Set<DateTime> selectedDates;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final sortedDates = selectedDates.toList()..sort();

    return Container(
      padding: const EdgeInsets.all(18),
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
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.indigoGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alarm Calendar', style: AppTextStyles.cardTitle),
                    const SizedBox(height: 4),
                    Text(
                      'Choose exact dates for this alarm.',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TableCalendar<dynamic>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 730)),
            focusedDay: focusedDay,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: AppTextStyles.cardTitle.copyWith(fontSize: 18),
              leftChevronIcon: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.primary,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: AppTextStyles.label.copyWith(
                color: AppColors.textMuted,
              ),
              weekendStyle: AppTextStyles.label.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              cellMargin: const EdgeInsets.all(4),
              defaultTextStyle: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
              ),
              weekendTextStyle: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              todayTextStyle: AppTextStyles.label.copyWith(
                color: AppColors.primary,
              ),
              selectedDecoration: BoxDecoration(
                gradient: AppColors.indigoGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [AppColors.softShadow],
              ),
              selectedTextStyle: AppTextStyles.label.copyWith(
                color: Colors.white,
              ),
            ),
            selectedDayPredicate: (day) {
              return selectedDates.contains(_dateOnly(day));
            },
            onDaySelected: (selectedDay, focusedDay) {
              onDaySelected(_dateOnly(selectedDay));
            },
            onPageChanged: onPageChanged,
          ),
          const SizedBox(height: 18),
          Text('Selected Alarm Dates', style: AppTextStyles.cardTitle),
          const SizedBox(height: 10),
          if (sortedDates.isEmpty)
            Text(
              'No alarm dates selected yet.',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sortedDates
                  .map(
                    (date) => _SelectedDateChip(
                      label: _formatDate(date),
                      onDeleted: () => onDaySelected(date),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} ${date.year}';
  }

  static String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}

class _SelectedDateChip extends StatelessWidget {
  const _SelectedDateChip({
    required this.label,
    required this.onDeleted,
  });

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      labelStyle: AppTextStyles.label.copyWith(color: AppColors.primary),
      deleteIcon: const Icon(Icons.close_rounded, size: 18),
      onDeleted: onDeleted,
      backgroundColor: AppColors.blueSoft,
      deleteIconColor: AppColors.primary,
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.16)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.soundName,
    required this.difficulty,
    required this.onSoundChanged,
    required this.onDifficultyChanged,
  });

  final String soundName;
  final String difficulty;
  final ValueChanged<String> onSoundChanged;
  final ValueChanged<String> onDifficultyChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        children: [
          _OptionRow(
            icon: Icons.music_note_rounded,
            title: 'Alarm Sound',
            subtitle: soundName,
            iconColor: AppColors.indigo,
            iconBackground: AppColors.purpleSoft,
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: soundName,
                borderRadius: BorderRadius.circular(18),
                items: const [
                  DropdownMenuItem(
                    value: 'Bright Morning',
                    child: Text('Bright Morning'),
                  ),
                  DropdownMenuItem(
                    value: 'Gentle Chime',
                    child: Text('Gentle Chime'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onSoundChanged(value);
                  }
                },
              ),
            ),
          ),
          const _RowDivider(),
          _OptionRow(
            icon: Icons.bar_chart_rounded,
            title: 'Challenge Difficulty',
            subtitle: difficulty,
            iconColor: AppColors.primary,
            iconBackground: AppColors.blueSoft,
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: difficulty,
                borderRadius: BorderRadius.circular(18),
                items: const [
                  DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onDifficultyChanged(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            title: 'Solve math challenge',
            subtitle: 'Answer the generated question correctly',
            difficulty: 'Required',
            iconBackground: AppColors.indigo,
          ),
          _RowDivider(),
          _ChallengeTile(
            selected: false,
            icon: Icons.lock_rounded,
            title: 'More challenges later',
            subtitle: 'Code and pattern challenges are planned',
            difficulty: 'Soon',
            iconBackground: AppColors.violet,
          ),
        ],
      ),
    );
  }
}

class _ChallengeInfoCard extends StatelessWidget {
  const _ChallengeInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  'The alarm only stops after the math challenge is solved.',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
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
          child: const Icon(
            Icons.notifications_active_rounded,
            color: AppColors.primary,
          ),
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

class _AlarmDays extends StatelessWidget {
  const _AlarmDays({
    required this.selectedDays,
    required this.onDayToggled,
  });

  static const List<_AlarmDayOption> _days = [
    _AlarmDayOption(label: 'S', value: 'Sun'),
    _AlarmDayOption(label: 'M', value: 'Mon'),
    _AlarmDayOption(label: 'T', value: 'Tue'),
    _AlarmDayOption(label: 'W', value: 'Wed'),
    _AlarmDayOption(label: 'T', value: 'Thu'),
    _AlarmDayOption(label: 'F', value: 'Fri'),
    _AlarmDayOption(label: 'S', value: 'Sat'),
  ];

  final List<String> selectedDays;
  final ValueChanged<String> onDayToggled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _days
          .map(
            (day) => _DayChip(
              label: day.label,
              active: selectedDays.contains(day.value),
              onTap: () => onDayToggled(day.value),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}

class _AlarmDayOption {
  const _AlarmDayOption({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
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
          const SizedBox(width: 10),
          Flexible(child: trailing),
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
