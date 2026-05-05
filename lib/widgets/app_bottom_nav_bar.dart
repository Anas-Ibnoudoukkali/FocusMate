import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_BottomNavItem> _items = [
    _BottomNavItem(
      label: 'Home',
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
    ),
    _BottomNavItem(
      label: 'Planner',
      activeIcon: Icons.calendar_month_rounded,
      inactiveIcon: Icons.calendar_month_outlined,
    ),
    _BottomNavItem(
      label: 'Focus',
      activeIcon: Icons.gps_fixed_rounded,
      inactiveIcon: Icons.gps_not_fixed_rounded,
    ),
    _BottomNavItem(
      label: 'Alarm',
      activeIcon: Icons.notifications_active_rounded,
      inactiveIcon: Icons.notifications_none_rounded,
    ),
    _BottomNavItem(
      label: 'Settings',
      activeIcon: Icons.settings_rounded,
      inactiveIcon: Icons.settings_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 88,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.border),
          boxShadow: [AppColors.softShadow],
        ),
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final active = index == currentIndex;
            final isFocus = item.label == 'Focus';

            return Expanded(
              child: Tooltip(
                message: item.label,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => onTap(index),
                  child: isFocus
                      ? _FocusNavItem(active: active, item: item)
                      : _StandardNavItem(active: active, item: item),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _StandardNavItem extends StatelessWidget {
  const _StandardNavItem({
    required this.active,
    required this.item,
  });

  final bool active;
  final _BottomNavItem item;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Icon(active ? item.activeIcon : item.inactiveIcon, color: color, size: 25),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              height: 1,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              letterSpacing: 0,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _FocusNavItem extends StatelessWidget {
  const _FocusNavItem({
    required this.active,
    required this.item,
  });

  final bool active;
  final _BottomNavItem item;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: AppColors.indigoGradient,
              shape: BoxShape.circle,
              boxShadow: [AppColors.glowShadow],
            ),
            child: Icon(
              active ? item.activeIcon : item.inactiveIcon,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                height: 1,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });

  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
}
