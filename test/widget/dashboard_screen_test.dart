// test/widgets/dashboard_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 1) Import the providers you need to override:
import 'package:lab_result_viewer/features/admin/Dashboard/provider/dashboard_provider.dart';
import 'package:lab_result_viewer/features/admin/Approval/provider/approval_notifier.dart';

// 2) Import the screen under test:
import 'package:lab_result_viewer/features/admin/Dashboard/screen/dashboard_screen.dart';
import 'package:lab_result_viewer/features/admin/Dashboard/model/dashboard_model.dart';


// 2b) Import the doubles helper:
import '../_dashboard_test_doubles.dart';

void main() {
  // Prepare a fake stats object
  final fakeStats = DashboardStats(
    totalAppointments: 5,
    totalPatients: 10,
    totalLabResults: 3,
    upcomingAppointments: [
      Appointment(time: '09:00 AM', patientId: 'p1', patientName: 'Alice', testType: 'Ultrasound'),
      Appointment(time: '10:30 AM', patientId: 'p2', patientName: 'Bob',   testType: 'MRI'),
    ],
  );

  Future<void> build(
    WidgetTester tester, {
    required DashboardState dashState,
    required bool hasPending,
  }) async {
    // Minimal GoRouter
    final router = GoRouter(
      initialLocation: '/admin-dashboard',
      routes: [GoRoute(path: '/admin-dashboard', builder: (_, __) => const DashboardScreen())],
    );

    // Build the widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // override the real dashboardProvider with our fake provider
          dashboardProvider.overrideWithProvider(
            makeFakeDashboardProvider(dashState),
          ),
          // override the boolean provider
          hasPendingAppointmentsProvider.overrideWithValue(hasPending),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('shows loading indicator', (tester) async {
    await build(tester, dashState: DashboardState(isLoading: true), hasPending: false);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders stats and upcoming list', (tester) async {
    await build(
      tester,
      dashState: DashboardState(isLoading: false, stats: fakeStats, hasFetched: true),
      hasPending: false,
    );

    // AppBar
    expect(find.text('Dashboard'), findsOneWidget);

    // Notification icon color
    final iconBtn = tester.widget<IconButton>(find.byIcon(Icons.notifications_outlined));
    expect((iconBtn.icon as Icon).color, equals(Colors.black));

    // Stat cards
    expect(find.text('Appointments'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Total Patients'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('Total Lab Results'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    // Upcoming header + entries
    expect(find.text('Upcoming Appointments'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Ultrasound'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('MRI'), findsOneWidget);

    // View all button
    expect(find.text('View All Appointments'), findsOneWidget);
  });

  testWidgets('shows empty upcoming message', (tester) async {
    final emptyStats = DashboardStats(
      totalAppointments: 0, totalPatients: 0, totalLabResults: 0, upcomingAppointments: [],
    );
    await build(
      tester,
      dashState: DashboardState(isLoading: false, stats: emptyStats, hasFetched: true),
      hasPending: false,
    );
    expect(find.text('No upcoming appointments'), findsOneWidget);
  });

  testWidgets('notification icon turns red if pending', (tester) async {
    await build(
      tester,
      dashState: DashboardState(isLoading: false, stats: fakeStats, hasFetched: true),
      hasPending: true,
    );
    final iconBtn = tester.widget<IconButton>(find.byIcon(Icons.notifications_outlined));
    expect((iconBtn.icon as Icon).color, equals(Colors.red));
  });
}

