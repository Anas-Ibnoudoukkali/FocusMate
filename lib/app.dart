import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_shell.dart';

const bool kEnableAuthFlow = false;

class FocusMateApp extends StatelessWidget {
  const FocusMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        title: 'FocusMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: kEnableAuthFlow ? const _AuthGate() : const MainShell(),
      ),
    );
  }
}

// Keep the login/register flow ready for later. Turn this auth gate back on
// after Firebase is configured by setting kEnableAuthFlow to true.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isInitializing) {
      return const _AppSplash();
    }

    if (auth.isAuthenticated) {
      return const MainShell();
    }

    return const LoginScreen();
  }
}

class _AppSplash extends StatelessWidget {
  const _AppSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
