import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final success = await context.read<AuthProvider>().register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
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
                  const SizedBox(height: 24),
                  Text('Create account', style: AppTextStyles.headline),
                  const SizedBox(height: 10),
                  Text(
                    'Set up your student workspace in a few seconds.',
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
                          if (auth.errorMessage != null) ...[
                            _InlineMessage(
                              message: auth.errorMessage!,
                              icon: Icons.error_outline_rounded,
                              color: AppColors.danger,
                              background: AppColors.dangerSoft,
                            ),
                            const SizedBox(height: 18),
                          ],
                          AppTextField(
                            controller: _nameController,
                            label: 'Name',
                            hint: 'Alex Johnson',
                            prefixIcon: Icons.person_outline_rounded,
                            validator: Validators.name,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 18),
                          AppTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'student@email.com',
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 18),
                          AppTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'At least 6 characters',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            validator: Validators.password,
                            textInputAction: TextInputAction.next,
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          AppTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm password',
                            hint: 'Repeat your password',
                            prefixIcon: Icons.verified_user_outlined,
                            obscureText: _obscureConfirmPassword,
                            validator: (value) => Validators.confirmPassword(
                              value,
                              _passwordController.text,
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            suffixIcon: IconButton(
                              tooltip: _obscureConfirmPassword
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          AppPrimaryButton(
                            label: 'Create Account',
                            icon: Icons.person_add_alt_1_rounded,
                            isLoading: auth.isLoading,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: TextButton(
                      onPressed: auth.isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        'Already have an account? Login',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                        ),
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

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.message,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String message;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
