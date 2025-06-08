import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import '../../home/providers/profile_provider.dart';
import '../../lab_results/screens/lab_results_screen.dart';
import '../../../core/auth/session_manager.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('Appts.')),
    const LabResultsScreen(),
    const Center(child: Text('Profile')), // TODO: Replace with ProfileScreen
  ];

  @override
  void initState() {
    super.initState();
    // Fetch profile data when the layout is initialized
    Future.microtask(() async {
      try {
        await ref.read(profileProvider.notifier).fetchProfile();
      } catch (e) {
        print('Error fetching profile in MainLayout: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading profile: ${e.toString()}')),
          );
        }
      }
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    print('Current user in MainLayout: ${profileState.name}');
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
} 