import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    await context.read<AuthProvider>().signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AuthBrandHeader(
                    title: 'Welcome back',
                    subtitle: 'Sign in and keep your study rhythm moving.',
                  ),
                  const SizedBox(height: 28),
                  _AuthCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (auth.errorMessage != null) ...[
                            _AuthMessage(
                              message: auth.errorMessage!,
                              icon: Icons.error_outline_rounded,
                              color: AppColors.danger,
                              background: AppColors.dangerSoft,
                            ),
                            const SizedBox(height: 18),
                          ],
                          AppTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'student@email.com',
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 18),
                          AppTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            validator: Validators.password,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
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
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: auth.isLoading
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                              child: Text(
                                'Forgot password?',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          AppPrimaryButton(
                            label: 'Login',
                            icon: Icons.arrow_forward_rounded,
                            isLoading: auth.isLoading,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New to FocusMate?',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: auth.isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                        child: Text(
                          'Create account',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
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

class _AuthBrandHeader extends StatelessWidget {
  const _AuthBrandHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: AppColors.indigoGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [AppColors.glowShadow],
          ),
          child: const Icon(
            Icons.shield_rounded,
            color: Colors.white,
            size: 42,
          ),
        ),
        const SizedBox(height: 28),
        Text(title, style: AppTextStyles.headline),
        const SizedBox(height: 10),
        Text(subtitle, style: AppTextStyles.body.copyWith(fontSize: 17)),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.softShadow],
      ),
      child: child,
    );
  }
}

class _AuthMessage extends StatelessWidget {
  const _AuthMessage({
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
