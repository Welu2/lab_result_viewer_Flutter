import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../widgets/stat_card.dart';
import '../../../../widgets/admin-bottom_bar.dart';
import "../provider/dashboard_provider.dart";
import '../../Approval/provider/approval_notifier.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(dashboardProvider.notifier);
      final hasFetched = ref.read(dashboardProvider).hasFetched;
      

      print('📌 InitState: hasFetched = $hasFetched');
      if (!hasFetched) {
        notifier.fetchDashboard();
      }
    });
  }


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
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final location =
        GoRouter.of(context).routeInformationProvider.value.location ?? '';
    final currentIndex = _getTabIndex(location);

final hasPendingAppointments = ref.watch(hasPendingAppointmentsProvider);

   
    if (dashboardState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (dashboardState.error != null) {
      return Scaffold(
        body: Center(child: Text('Error: ${dashboardState.error}')),
      );
    }

    final stats = dashboardState.stats;
    if (stats == null) {
      return const Scaffold(
        body: Center(child: Text('No dashboard data available')),
      );
    }

    final upcomingAppointments = stats.upcomingAppointments;

    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Dashboard', style: TextStyle(color: Colors.black)),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.black,
                  size: 30,
                ),
                onPressed: () {
                  context.go("/appointments-approval");
                },
              ),
              if (hasPendingAppointments)
                Positioned(
                  right: 8,
                  top: 8,
                  child: SizedBox(
                    width: 10,
                    height: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome back, Admin',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  StatCard(
                    icon: Icons.calendar_today,
                    label: 'Appointments',
                    value: stats.totalAppointments.toString(),
                    badge: 'Today',
                  ),
                  StatCard(
                    icon: Icons.group,
                    label: 'Total Patients',
                    value: stats.totalPatients.toString(),
                  ),
                  StatCard(
                    icon: Icons.check_circle,
                    label: 'Total Lab Results',
                    value: stats.totalLabResults.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Upcoming Appointments',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: upcomingAppointments.isEmpty
                      ? const Text("No upcoming appointments")
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...upcomingAppointments.map(
                              (appt) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        appt.time,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(appt.patientName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(appt.testType,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13)),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/admin-appt'),
                              child: Text(
                                "View All Appointments",
                                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
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
