import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../models/task_model.dart';
import '../../providers/focus_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/app_gradient_card.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/section_title.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final settings = context.watch<SettingsProvider>();

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
                _DailyGoalCard(
                  taskProvider: taskProvider,
                  dailyGoalMinutes: settings.dailyGoalMinutes,
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
                          '${taskProvider.totalTasks} tasks',
                          style: AppTextStyles.label,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Local',
                        style: AppTextStyles.label.copyWith(fontSize: 16),
                      ),
                      const Icon(
                        Icons.offline_pin_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _TaskListCard(taskProvider: taskProvider),
                const SizedBox(height: 22),
                _ProgressCard(taskProvider: taskProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({
    required this.taskProvider,
    required this.dailyGoalMinutes,
  });

  final TaskProvider taskProvider;
  final int dailyGoalMinutes;

  @override
  Widget build(BuildContext context) {
    final minuteProgress = dailyGoalMinutes == 0
        ? 0.0
        : (taskProvider.completedMinutes / dailyGoalMinutes)
            .clamp(0, 1)
            .toDouble();

    return AppGradientCard(
      title: 'Daily Goal',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            const Icon(Icons.save_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Saved Local',
              style: AppTextStyles.label.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _GoalMetric(
              icon: Icons.access_time_filled_rounded,
              label: 'Study Time',
              value: _formatMinutes(taskProvider.completedMinutes),
              caption: 'of ${_formatMinutes(dailyGoalMinutes)} goal',
              progress: minuteProgress,
            ),
          ),
          const _GoalDivider(),
          Expanded(
            child: _GoalMetric(
              icon: Icons.track_changes_rounded,
              label: 'Tasks',
              value: '${taskProvider.completedTasks}',
              caption: 'of ${taskProvider.totalTasks} tasks',
              progress: taskProvider.taskProgress,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskListCard extends StatelessWidget {
  const _TaskListCard({required this.taskProvider});

  final TaskProvider taskProvider;

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
          if (taskProvider.isLoading)
            const Padding(
              padding: EdgeInsets.all(28),
              child: CircularProgressIndicator(),
            )
          else if (taskProvider.tasks.isEmpty)
            const _EmptyTaskState()
          else
            ...List.generate(taskProvider.tasks.length, (index) {
              final task = taskProvider.tasks[index];

              return Column(
                children: [
                  Dismissible(
                    key: ValueKey(task.id),
                    direction: DismissDirection.endToStart,
                    background: const _DeleteBackground(),
                    onDismissed: (_) => taskProvider.deleteTask(task.id),
                    child: _TaskTile(
                      task: task,
                      color: _subjectColor(task.subject),
                      primaryAction: !task.isCompleted && index == 0,
                      onToggle: () => taskProvider.toggleTask(task.id),
                      onDelete: () => taskProvider.deleteTask(task.id),
                      onStart: () {
                        context.read<FocusProvider>().startSession(task);
                        context
                            .read<NavigationProvider>()
                            .setSection(AppSection.focus);
                      },
                    ),
                  ),
                  if (index != taskProvider.tasks.length - 1)
                    const _TaskDivider(),
                ],
              );
            }),
          const Divider(height: 1, color: AppColors.border),
          TextButton.icon(
            onPressed: () => _showAddTaskSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Add Task',
              style: AppTextStyles.label.copyWith(fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          if (taskProvider.errorMessage != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Text(
                taskProvider.errorMessage!,
                style: AppTextStyles.body.copyWith(color: AppColors.danger),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.taskProvider});

  final TaskProvider taskProvider;

  @override
  Widget build(BuildContext context) {
    final progress = taskProvider.taskProgress;

    return Container(
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
                Text(_progressMessage(progress), style: AppTextStyles.body),
              ],
            ),
          ),
          _MiniProgressRing(progress: progress),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${taskProvider.completedTasks} of '
                  '${taskProvider.totalTasks} tasks completed',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 10),
                _ProgressBar(progress: progress),
                const SizedBox(height: 10),
                Text(
                  '${taskProvider.remainingTasks} tasks remaining',
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
    required this.progress,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final double progress;

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
        Text(label, style: AppTextStyles.body.copyWith(color: Colors.white)),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.title.copyWith(
            color: Colors.white,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 4),
        Text(caption, style: AppTextStyles.body.copyWith(color: Colors.white)),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progress,
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
    required this.task,
    required this.color,
    required this.onToggle,
    required this.onDelete,
    this.primaryAction = false,
    this.onStart,
  });

  final TaskModel task;
  final Color color;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final bool primaryAction;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: task.isCompleted ? AppColors.indigoGradient : null,
                color: task.isCompleted ? null : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: task.isCompleted
                    ? null
                    : Border.all(color: AppColors.textMuted, width: 1.4),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 22)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTextStyles.cardTitle.copyWith(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _SubjectChip(label: task.subject, color: color),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${task.estimatedMinutes} min',
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (!task.isCompleted)
            _StartFocusButton(primary: primaryAction, onTap: onStart)
          else
            IconButton(
              tooltip: 'Delete task',
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
            ),
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
  const _SubjectChip({required this.label, required this.color});

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
      child: Text(label, style: AppTextStyles.label.copyWith(color: color)),
    );
  }
}

class _StartFocusButton extends StatelessWidget {
  const _StartFocusButton({required this.primary, this.onTap});

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

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      color: AppColors.dangerSoft,
      child: const Icon(Icons.delete_rounded, color: AppColors.danger),
    );
  }
}

class _EmptyTaskState extends StatelessWidget {
  const _EmptyTaskState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: AppColors.blueSoft,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.playlist_add_check_rounded,
              color: AppColors.primary,
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          Text('No tasks yet', style: AppTextStyles.cardTitle),
          const SizedBox(height: 6),
          Text(
            'Add your first study task to start tracking progress.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _minutesController = TextEditingController(text: '25');
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    await context.read<TaskProvider>().addTask(
          title: _titleController.text,
          subject: _subjectController.text,
          estimatedMinutes: int.parse(_minutesController.text.trim()),
        );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 18,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
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
            Text('Add Task', style: AppTextStyles.title),
            const SizedBox(height: 6),
            Text('Create a local study task for today.', style: AppTextStyles.body),
            const SizedBox(height: 22),
            AppTextField(
              controller: _titleController,
              label: 'Task title',
              hint: 'Read chapter 3',
              prefixIcon: Icons.task_alt_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  Validators.requiredField(value, label: 'Task title'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _subjectController,
              label: 'Subject',
              hint: 'Mathematics',
              prefixIcon: Icons.school_outlined,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  Validators.requiredField(value, label: 'Subject'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _minutesController,
              label: 'Estimated minutes',
              hint: '25',
              prefixIcon: Icons.schedule_rounded,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              validator: _validateMinutes,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: 'Save Task',
              icon: Icons.add_task_rounded,
              isLoading: _isSaving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  String? _validateMinutes(String? value) {
    final minutes = int.tryParse(value?.trim() ?? '');

    if (minutes == null) {
      return 'Enter a valid number';
    }
    if (minutes < 5 || minutes > 240) {
      return 'Use 5 to 240 minutes';
    }
    return null;
  }
}

void _showAddTaskSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (_) => const _AddTaskSheet(),
  );
}

Color _subjectColor(String subject) {
  final normalized = subject.toLowerCase();

  if (normalized.contains('math') || normalized.contains('calculus')) {
    return AppColors.primary;
  }
  if (normalized.contains('bio') || normalized.contains('science')) {
    return AppColors.success;
  }
  if (normalized.contains('spanish') || normalized.contains('language')) {
    return AppColors.warning;
  }
  if (normalized.contains('psych') || normalized.contains('reading')) {
    return AppColors.violet;
  }
  return AppColors.indigo;
}

String _formatMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (hours == 0) {
    return '${remainingMinutes}m';
  }
  return '${hours}h ${remainingMinutes.toString().padLeft(2, '0')}m';
}

String _progressMessage(double progress) {
  if (progress == 0) {
    return 'Add momentum with one small win.';
  }
  if (progress >= 1) {
    return 'All done. Beautiful work.';
  }
  if (progress >= 0.5) {
    return 'Great job! Keep going.';
  }
  return 'You are getting started.';
}
