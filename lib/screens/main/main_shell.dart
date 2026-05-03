import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/navigation_provider.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import 'alarm_screen.dart';
import 'dashboard_screen.dart';
import 'focus_screen.dart';
import 'home_screen.dart';
import 'planner_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    PlannerScreen(),
    FocusScreen(),
    AlarmScreen(),
    DashboardScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<NavigationProvider>();

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: navigation.currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigation.currentIndex,
        onTap: navigation.setIndex,
      ),
    );
  }
}
