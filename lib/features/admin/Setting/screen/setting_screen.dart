import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import "../../../../widgets/admin-setting.dart";
import "../../../auth/providers/auth_provider.dart";
import "../../../../widgets/admin-bottom_bar.dart";

class AdminSettingsScreen extends ConsumerWidget {
  final VoidCallback? onBack;

  const AdminSettingsScreen({Key? key, this.onBack}) : super(key: key);

  int _getTabIndex(String location) {
    const tabRoutes = [
      '/admin-dashboard',
      '/patients',
      '/admin-upload',
      '/admin-appt',
      '/setting',
    ];
    final index = tabRoutes.indexWhere((route) => location.startsWith(route));
    return index != -1 ? index : 0;
  }

  void _handleTabTap(BuildContext context, int index) {
    const tabRoutes = [
      '/admin-dashboard',
      '/patients',
      '/admin-upload',
      '/admin-appt',
      '/setting',
    ];
    context.go(tabRoutes[index]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);

    final location =
        GoRouter.of(context).routeInformationProvider.value?.location ?? '';
    final currentIndex = _getTabIndex(location);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  IconButton(
                    onPressed: onBack ?? () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Settings",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  "Manage your account and app preferences",
                  style: TextStyle(color: Color(0xFF8E99A8), fontSize: 15),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Account",
                style: TextStyle(
                  color: Color(0xFF8E99A8),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: const Color(0xFFF8F8F8),
                child: Column(
                  children: [
                    AdminSettingsItem(
                      icon: Icons.person,
                      text: 'Profile Information',
                      onTap: () {},
                    ),
                    const Divider(),
                    AdminSettingsItem(
                      icon: Icons.notifications,
                      text: 'Notifications',
                      onTap: () {},
                    ),
                    const Divider(),
                    AdminSettingsItem(
                      icon: Icons.security,
                      text: 'Security',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Card(
                color: const Color(0x1AFF0000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 90),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: Color(0xFFFF3B30)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          await authNotifier.logout(); // Riverpod logout
                          if (context.mounted) {
                            context.go('/welcome');
                          }
                        },
                        child: const Text(
                          "Log Out",
                          style: TextStyle(
                            color: Color(0xFFFF3B30),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: currentIndex,
        onTap: (index) => _handleTabTap(context, index),
      ),
    );
  }
}
