import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_mate/widgets/app_primary_button.dart';

void main() {
  testWidgets('AppPrimaryButton renders its label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPrimaryButton(
            label: 'Login',
            icon: Icons.login_rounded,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Login'), findsOneWidget);
    expect(find.byIcon(Icons.login_rounded), findsOneWidget);
  });
}
