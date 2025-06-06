import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import '../providers/profile_provider.dart';
import 'package:provider/provider.dart';
import '../../lab_results/screens/lab_results_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LabResultsScreen(),
    const Center(child: Text('Profile')), // TODO: Replace with ProfileScreen
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    print('Current user in MainLayout: ${profileProvider.name}');
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
} 