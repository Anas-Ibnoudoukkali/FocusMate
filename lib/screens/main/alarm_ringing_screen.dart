import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/alarm_provider.dart';
import '../../widgets/app_gradient_card.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';

class AlarmRingingScreen extends StatefulWidget {
  const AlarmRingingScreen({super.key});

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submit() {
    final stopped = context
        .read<AlarmProvider>()
        .tryStopAlarm(_answerController.text);

    if (!stopped) {
      _answerController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final alarm = context.watch<AlarmProvider>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wake Up', style: AppTextStyles.headline),
                  const SizedBox(height: 10),
                  Text(
                    'Complete the challenge to stop the alarm.',
                    style: AppTextStyles.body.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 28),
                  AppGradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.alarm_rounded,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alarm.nextAlarmLabel,
                                    style: AppTextStyles.display.copyWith(
                                      color: Colors.white,
                                      fontSize: 42,
                                    ),
                                  ),
                                  Text(
                                    'Alarm ringing',
                                    style: AppTextStyles.body.copyWith(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          '${alarm.challengeQuestion} = ?',
                          style: AppTextStyles.display.copyWith(
                            color: Colors.white,
                            fontSize: 54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                        AppTextField(
                          controller: _answerController,
                          label: 'Challenge answer',
                          hint: 'Enter the result',
                          prefixIcon: Icons.calculate_rounded,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        if (alarm.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            alarm.errorMessage!,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        AppPrimaryButton(
                          label: 'Stop Alarm',
                          icon: Icons.check_circle_rounded,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
