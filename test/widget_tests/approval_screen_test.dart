// test/widget/approval_screen_test.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lab_result_viewer/features/admin/Approval/screen/approval_screen.dart';
import 'package:lab_result_viewer/features/admin/Approval/provider/approval_notifier.dart';
import 'package:lab_result_viewer/features/admin/Approval/models/approval_model.dart';


void main() {
  final pendingAppt = Appointment(
    id: 1,
    status: 'pending',
    date: '2025-06-15',
    time: '10:30 AM',
    testType: 'MRI',
    patient: Patient(patientId: 'P123'),
  );

  Future<void> _pump(
    WidgetTester tester, {
    required List<Appointment> approvals,
    GoRouter? router,
  }) async {
    router ??= GoRouter(
      initialLocation: '/admin-approve',
      routes: [
        GoRoute(path: '/admin-approve', builder: (_, __) => const AppointmentsApprovalScreen()),
        GoRoute(path: '/admin-dashboard', builder: (_, __) => const Scaffold()),
      ],
    );

    final fake = AsyncNotifierProvider<AppointmentNotifier, List<Appointment>>(
      () => _ImmediateNotifier(approvals),
    );

    await tester.pumpWidget(
      ProviderScope(overrides: [
        appointmentNotifierProvider.overrideWithProvider(fake),
      ], child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty => shows no-pending message', (tester) async {
    await _pump(tester, approvals: []);
    expect(find.text('No appointments waiting for approval'), findsOneWidget);
  });

  testWidgets('data => shows card with Approve/Decline', (tester) async {
    await _pump(tester, approvals: [pendingAppt]);

    // Check the header
    expect(find.text('1 appointments waiting for approval'), findsOneWidget);
    // Check patient ID line
    expect(find.textContaining('ID: P123'), findsOneWidget);
    // Now simply look for the button labels in the UI:
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);
  });

  testWidgets('back arrow navigates to dashboard', (tester) async {
    bool wentHome = false;
    final router = GoRouter(
      initialLocation: '/admin-approve',
      routes: [
        GoRoute(path: '/admin-approve', builder: (_, __) => const AppointmentsApprovalScreen()),
        GoRoute(path: '/admin-dashboard', builder: (_, __) {
          wentHome = true;
          return const Scaffold();
        }),
      ],
    );
    await _pump(tester, approvals: [], router: router);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(wentHome, isTrue);
  });
}

class _ImmediateNotifier extends AppointmentNotifier {
  final List<Appointment> _data;
  _ImmediateNotifier(this._data);

  @override
  Future<List<Appointment>> build() async {
    state = AsyncData(_data);
    return _data;
  }
}
