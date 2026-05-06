import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/task_model.dart';
import '../../providers/focus_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/task_provider.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final focus = context.watch<FocusProvider>();

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
                _SelectedTaskCard(focus: focus),
                const SizedBox(height: 18),
                _TimerCard(focus: focus),
                const SizedBox(height: 18),
                _DistractionCard(focus: focus),
                const SizedBox(height: 18),
                _ControlCard(focus: focus),
                if (focus.isReview) ...[
                  const SizedBox(height: 18),
                  _SessionReviewCard(focus: focus),
                ] else ...[
                  const SizedBox(height: 18),
                  _LiveReviewCard(focus: focus),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedTaskCard extends StatelessWidget {
  const _SelectedTaskCard({required this.focus});

  final FocusProvider focus;

  @override
  Widget build(BuildContext context) {
    final task = focus.selectedTask;
    final session = focus.lastSession;
    final title = task?.subject ?? session?.subject ?? 'Select Task';
    final subtitle = task?.title ?? session?.taskTitle ?? 'Choose a planner task';
    final canSelect = !focus.isActive && !focus.isReview;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: canSelect ? () => _showTaskPicker(context) : null,
        child: Ink(
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
                child: Icon(
                  task == null && session == null
                      ? Icons.add_task_rounded
                      : Icons.code_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(fontSize: 17),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                canSelect ? Icons.chevron_right_rounded : Icons.track_changes_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({required this.focus});

  final FocusProvider focus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Pill(
                icon: Icons.timer_outlined,
                label: _statusLabel(focus),
                color: AppColors.primary,
                background: AppColors.blueSoft,
              ),
              _Pill(
                icon: Icons.shield_rounded,
                label: focus.strictMode ? 'Strict Mode Active' : 'Strict Mode Off',
                color: focus.strictMode
                    ? AppColors.success
                    : AppColors.textSecondary,
                background: focus.strictMode
                    ? AppColors.successSoft
                    : AppColors.cardSoft,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _TimerRing(focus: focus),
        ],
      ),
    );
  }
}

class _DistractionCard extends StatelessWidget {
  const _DistractionCard({required this.focus});

  final FocusProvider focus;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    Text('${focus.distractions}', style: AppTextStyles.title),
                    Text(
                      focus.distractions == 0
                          ? 'Keep it up! You\'re doing great.'
                          : 'Logged. Refocus and continue.',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ],
          );

          final button = _SoftActionButton(
            label: 'I got distracted',
            icon: Icons.close_rounded,
            color: AppColors.danger,
            background: AppColors.dangerSoft,
            onTap: focus.isActive ? focus.addDistraction : null,
          );

          if (constraints.maxWidth < 360) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                details,
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerRight, child: button),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: details),
              const SizedBox(width: 12),
              button,
            ],
          );
        },
      ),
    );
  }
}

class _ControlCard extends StatelessWidget {
  const _ControlCard({required this.focus});

  final FocusProvider focus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.softShadow],
      ),
      child: Row(
        children: [
          Expanded(child: _buildPrimaryControl(context)),
          const SizedBox(width: 14),
          Expanded(
            child: _ControlButton(
              label: focus.isReview ? 'Planner' : 'End Session',
              icon: focus.isReview ? Icons.calendar_month_rounded : Icons.stop_rounded,
              color: focus.isReview ? AppColors.primary : AppColors.danger,
              background: focus.isReview ? AppColors.blueSoft : AppColors.dangerSoft,
              onTap: focus.isReview
                  ? () => context
                      .read<NavigationProvider>()
                      .setSection(AppSection.planner)
                  : focus.isActive
                      ? () => focus.endSessionEarly()
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryControl(BuildContext context) {
    if (focus.isReview) {
      return _ControlButton(
        label: 'New Session',
        icon: Icons.refresh_rounded,
        color: AppColors.primary,
        background: AppColors.blueSoft,
        onTap: focus.clearReview,
      );
    }

    if (focus.isRunning) {
      return _ControlButton(
        label: 'Pause',
        icon: Icons.pause_rounded,
        color: AppColors.primary,
        background: AppColors.blueSoft,
        onTap: focus.pause,
      );
    }

    if (focus.isPaused) {
      return _ControlButton(
        label: 'Resume',
        icon: Icons.play_arrow_rounded,
        color: AppColors.primary,
        background: AppColors.blueSoft,
        onTap: focus.resume,
      );
    }

    return _ControlButton(
      label: 'Start Focus',
      icon: Icons.play_arrow_rounded,
      color: AppColors.primary,
      background: AppColors.blueSoft,
      onTap: focus.startSelectedTask,
    );
  }
}

class _LiveReviewCard extends StatelessWidget {
  const _LiveReviewCard({required this.focus});

  final FocusProvider focus;

  @override
  Widget build(BuildContext context) {
    final progress = focus.progress;

    return Container(
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
                    Text('Session Review (Live)', style: AppTextStyles.cardTitle),
                    const SizedBox(height: 6),
                    Text(_liveMessage(focus), style: AppTextStyles.body),
                  ],
                ),
              ),
              _Pill(
                icon: Icons.trending_up_rounded,
                label: focus.isActive ? 'In progress' : 'Ready',
                color: AppColors.success,
                background: AppColors.successSoft,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _ReviewMetric(
                  icon: Icons.do_not_disturb_alt_rounded,
                  value: '${focus.distractions}',
                  label: 'Distractions',
                  color: AppColors.danger,
                  background: AppColors.dangerSoft,
                ),
              ),
              const _VerticalDivider(),
              Expanded(
                child: _ReviewMetric(
                  icon: Icons.output_rounded,
                  value: '${focus.exitAttempts}',
                  label: 'Exit Attempts',
                  color: AppColors.warning,
                  background: AppColors.warningSoft,
                ),
              ),
              const _VerticalDivider(),
              Expanded(
                child: _ReviewMetric(
                  icon: Icons.check_circle_outline_rounded,
                  value: '${(progress * 100).round()}%',
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
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: AppColors.blueSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text('Keep going - you\'ve got this!', style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _SessionReviewCard extends StatelessWidget {
  const _SessionReviewCard({required this.focus});

  final FocusProvider focus;

  @override
  Widget build(BuildContext context) {
    final session = focus.lastSession;

    if (session == null) {
      return const SizedBox.shrink();
    }

    return Container(
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
                    Text('Session Saved', style: AppTextStyles.cardTitle),
                    const SizedBox(height: 6),
                    Text(
                      session.completed
                          ? 'Linked task marked completed.'
                          : 'Session ended early. Task stays open.',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
              const _Pill(
                icon: Icons.check_circle_outline_rounded,
                label: 'Done',
                color: AppColors.success,
                background: AppColors.successSoft,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _ReviewMetric(
                  icon: Icons.timer_outlined,
                  value: _formatElapsed(session.elapsedSeconds),
                  label: 'Focused',
                  color: AppColors.primary,
                  background: AppColors.blueSoft,
                ),
              ),
              const _VerticalDivider(),
              Expanded(
                child: _ReviewMetric(
                  icon: Icons.do_not_disturb_alt_rounded,
                  value: '${session.distractions}',
                  label: 'Distractions',
                  color: AppColors.danger,
                  background: AppColors.dangerSoft,
                ),
              ),
              const _VerticalDivider(),
              Expanded(
                child: _ReviewMetric(
                  icon: Icons.task_alt_rounded,
                  value: 'Saved',
                  label: 'Session',
                  color: AppColors.success,
                  background: AppColors.successSoft,
                ),
              ),
            ],
          ),
          if (focus.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              focus.errorMessage!,
              style: AppTextStyles.body.copyWith(color: AppColors.danger),
            ),
          ],
        ],
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
          Text(label, style: AppTextStyles.label.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _TimerRing extends StatelessWidget {
  const _TimerRing({required this.focus});

  final FocusProvider focus;

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
                  value: focus.progress,
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
                    focus.formattedRemaining,
                    style: AppTextStyles.display.copyWith(fontSize: 52),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    focus.isReview ? 'completed' : 'remaining',
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
                    child: Text(
                      focus.hasSelectedTask
                          ? focus.formattedDuration
                          : '${focus.formattedDuration} default',
                      style: AppTextStyles.label,
                    ),
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

class _SoftActionButton extends StatelessWidget {
  const _SoftActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.52 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
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
              Text(label, style: AppTextStyles.label.copyWith(color: color)),
            ],
          ),
        ),
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
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.52 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
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
        ),
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
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.title.copyWith(fontSize: 20),
        ),
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

class _TaskPickerSheet extends StatelessWidget {
  const _TaskPickerSheet();

  @override
  Widget build(BuildContext context) {
    final tasks = context
        .watch<TaskProvider>()
        .tasks
        .where((task) => !task.isCompleted)
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 18,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Select Task', style: AppTextStyles.title),
          const SizedBox(height: 6),
          Text('Pick a planner task to focus on.', style: AppTextStyles.body),
          const SizedBox(height: 18),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'No open tasks. Add one in Planner first.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: tasks.length,
                separatorBuilder: (_, _) =>
                    const Divider(color: AppColors.border),
                itemBuilder: (context, index) {
                  final task = tasks[index];

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.blueSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.task_alt_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(task.title, style: AppTextStyles.cardTitle),
                    subtitle: Text(
                      '${task.subject} - ${task.estimatedMinutes} min',
                      style: AppTextStyles.body,
                    ),
                    onTap: () {
                      context.read<FocusProvider>().selectTask(task);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

void _showTaskPicker(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (_) => const _TaskPickerSheet(),
  );
}

String _statusLabel(FocusProvider focus) {
  switch (focus.status) {
    case FocusSessionStatus.running:
      return 'Running';
    case FocusSessionStatus.paused:
      return 'Paused';
    case FocusSessionStatus.review:
      return 'Review';
    case FocusSessionStatus.idle:
      return focus.hasSelectedTask ? 'Ready' : 'Default timer';
  }
}

String _liveMessage(FocusProvider focus) {
  if (!focus.hasSelectedTask) {
    return 'Start a quick session or select a task.';
  }
  if (focus.isPaused) {
    return 'Paused. Resume when ready.';
  }
  if (focus.isRunning) {
    return 'You\'re on track!';
  }
  return 'Ready to start.';
}

String _formatElapsed(int seconds) {
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;

  if (minutes == 0) {
    return '${remainingSeconds}s';
  }
  return '${minutes}m';
}
