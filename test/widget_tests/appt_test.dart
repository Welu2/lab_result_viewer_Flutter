// appointments_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lab_result_viewer/features/admin/appointment/screen/appt.dart'; // adjust the import as needed
import 'package:lab_result_viewer/features/admin/appointment/provider/appt_provider.dart';
import 'package:lab_result_viewer/features/admin/appointment/service/appt_service.dart';

// Assuming Appointment & Patient live here.
import 'package:lab_result_viewer/core/api/api_client.dart'; // Import the ApiClient

// test/widget/appt_test.dart

import 'package:dio/dio.dart';

import 'package:lab_result_viewer/features/admin/Approval/models/approval_model.dart';

// test/widget/appt_test.dart


/// A fake API client that extends the production ApiClient.
/// It overrides the get method to return a dummy Response.
// test/widget/appointments_screen_test.dart

import 'dart:async';


// test/widget/appointments_screen_test.dart


void main() {
  // Create a “today” appointment
  final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final mockAppt = Appointment(
    id: 1,
    testType: 'Blood Test',
    date: todayStr,
    time: '09:00 AM',
    status: 'confirmed',
    patient: Patient(
      patientId: 'p1',
     
    ),
  );

  /// Pumps the screen with different futures per filter
  Future<void> _build(
    WidgetTester tester, {
    required Future<List<Appointment>> todayFuture,
    required Future<List<Appointment>> upcomingFuture,
    required Future<List<Appointment>> pastFuture,
    GoRouter? router,
  }) async {
    router ??= GoRouter(
      initialLocation: '/admin-appt',
      routes: [
        GoRoute(path: '/admin-appt', builder: (_, __) => const AppointmentsScreen()),
      ],
    );

    // Override the family provider directly:
    final override = appointmentsProvider.overrideWith((ref, filter) {
      switch (filter) {
        case 'today':
          return todayFuture;
        case 'upcoming':
          return upcomingFuture;
        case 'past':
          return pastFuture;
        default:
          return Future.value([]);
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [override],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  testWidgets('shows loading spinner while appointments are loading', (tester) async {
    final completer = Completer<List<Appointment>>();
    await _build(
      tester,
      todayFuture: completer.future,
      upcomingFuture: Future.value([]),
      pastFuture: Future.value([]),
    );
    await tester.pump(); // start build

    // Spinner should be visible while the future is still pending:
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete and settle:
    completer.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('shows empty state when there are no today appointments', (tester) async {
    await _build(
      tester,
      todayFuture: Future.value([]),
      upcomingFuture: Future.value([]),
      pastFuture: Future.value([]),
    );
    await tester.pumpAndSettle();

    // No ListTile means empty:
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('renders today\'s appointment', (tester) async {
    await _build(
      tester,
      todayFuture: Future.value([mockAppt]),
      upcomingFuture: Future.value([]),
      pastFuture: Future.value([]),
    );
    await tester.pumpAndSettle();

    // Leading icon for time:
    expect(find.byIcon(Icons.access_time), findsOneWidget);
    // The time text:
    expect(find.text('09:00 AM'), findsOneWidget);
    // The testType and patientId:
    expect(find.text('Blood Test'), findsOneWidget);
    expect(find.text('p1'), findsOneWidget);
    // The formatted date:
    final expectedDate = DateFormat('MMM d').format(DateTime.parse(todayStr));
    expect(find.text(expectedDate), findsOneWidget);
  });

  testWidgets('switching to Upcoming shows upcoming appointments', (tester) async {
    await _build(
      tester,
      todayFuture: Future.value([]),
      upcomingFuture: Future.value([mockAppt]),
      pastFuture: Future.value([]),
    );
    await tester.pumpAndSettle();

    // Tap “Upcoming” tab:
    await tester.tap(find.text('Upcoming'));
    await tester.pumpAndSettle();

    // Should now show the same tile under Upcoming:
    expect(find.text('09:00 AM'), findsOneWidget);
  });
}
