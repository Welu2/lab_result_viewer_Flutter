import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_summary_provider.dart';
import '../../lab_results/providers/lab_results_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../providers/profile_provider.dart';
import '../../../core/auth/session_manager.dart';
import 'package:go_router/go_router.dart';

import '../widgets/home_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String search = '';
  final List<String> _services = [
    'Ultrasound',
    'CT Scan',
    'MRI',
    'Blood Work'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).fetchProfile();
      SessionManager().getToken().then((token) {
        if (token != null) {
          ref
              .read(notificationProvider.notifier)
              .fetchNotifications(token);
        }
      });
    });
  }

  Future<void> _onRefresh() async {
    final token = await SessionManager().getToken();
    await Future.wait([
      ref.read(profileProvider.notifier).fetchProfile(),
      ref.read(healthSummaryProvider.notifier).fetchSummary(),
      if (token != null)
        ref.read(notificationProvider.notifier).fetchNotifications(token),
      ref.read(labResultsProvider.notifier).fetchLabResults(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final health = ref.watch(healthSummaryProvider);
    final notif = ref.watch(notificationProvider);

    return HomeView(
      userName: profile.name ?? '',
      unreadNotifications: notif.unreadCount,
      totalTests: health.totalTests,
      abnormalResults: health.abnormalResults,
      services: _services,
      onNotificationsTap: () => context.go('/notifications'),
      onRefresh: _onRefresh,
      onSearchChanged: (val) => setState(() => search = val),
      onServiceTap: (_) {/* your existing empty handler */},
    );
  }
}
