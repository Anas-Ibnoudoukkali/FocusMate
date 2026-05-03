import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final success = await context
        .read<AuthProvider>()
        .sendPasswordReset(_emailController.text);

    if (success && mounted) {
      setState(() {
        _sent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: auth.isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.card,
                      fixedSize: const Size(56, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(height: 28),
                  Text('Reset password', style: AppTextStyles.headline),
                  const SizedBox(height: 10),
                  Text(
                    'Enter your email and FocusMate will send a reset link.',
                    style: AppTextStyles.body.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [AppColors.softShadow],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (_sent) ...[
                            const _SuccessMessage(),
                            const SizedBox(height: 18),
                          ] else if (auth.errorMessage != null) ...[
                            _ErrorMessage(message: auth.errorMessage!),
                            const SizedBox(height: 18),
                          ],
                          AppTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'student@email.com',
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 24),
                          AppPrimaryButton(
                            label: _sent ? 'Send Again' : 'Send Reset Link',
                            icon: Icons.mark_email_read_outlined,
                            isLoading: auth.isLoading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 14),
                          AppPrimaryButton(
                            label: 'Back to Login',
                            icon: Icons.arrow_back_rounded,
                            isOutlined: true,
                            isExpanded: true,
                            onPressed: auth.isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  const _SuccessMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Reset link sent. Check your inbox.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
