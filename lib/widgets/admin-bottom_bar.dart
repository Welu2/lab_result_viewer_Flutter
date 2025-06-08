import 'package:flutter/material.dart';
import "../core/theme/app_theme.dart";

class MainBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const MainBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  static const _tabs = [
    {'label': 'Home', 'icon': Icons.home},
    {'label': 'Patient', 'icon': Icons.people},
    {'label': 'Upload', 'icon': Icons.add},
    {'label': 'Appts', 'icon': Icons.calendar_today},
    {'label': 'Settings', 'icon': Icons.settings},
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap, // ✅ Make sure this matches the parameter!
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: _tabs
          .map(
            (tab) => BottomNavigationBarItem(
              icon: Icon(tab['icon'] as IconData),
              label: tab['label'] as String,
            ),
          )
          .toList(),
    );
  }
}
