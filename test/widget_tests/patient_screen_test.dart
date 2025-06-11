// test/widget/patient_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lab_result_viewer/features/admin/Patient/model/patient_profile.dart';
import 'package:lab_result_viewer/features/admin/Patient/provider/patient_provider.dart';
import 'package:lab_result_viewer/features/admin/Patient/screen/patient_screen.dart';
import 'package:lab_result_viewer/features/admin/Patient/service/patient_service.dart';
import 'package:lab_result_viewer/core/api/api_client.dart';


import 'package:lab_result_viewer/features/admin/Patient/screen/register_create_profile_dialog.dart';
import 'package:lab_result_viewer/features/admin/Patient/screen/view_profile_dialog.dart';
import 'package:lab_result_viewer/features/admin/Patient/screen/edit_profile_dialog.dart';
import 'package:lab_result_viewer/features/auth/providers/auth_provider.dart';


class FakePatientService extends PatientService {
  final List<PatientProfile> _data;
  FakePatientService(this._data) : super(ApiClient());

  @override
  Future<List<PatientProfile>> fetchAllPatients() async {
    // Simulate a small delay
    await Future.delayed(Duration(milliseconds: 10));
    return _data;
  }
}

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/patients',
      routes: [
        GoRoute(path: '/patients', builder: (_, __) => const PatientScreen()),
      ],
    );
  });

  Future<void> pumpPatientScreen(
    WidgetTester tester,
    List<PatientProfile> patients,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Inject our fake service
          patientServiceProvider.overrideWithValue(FakePatientService(patients)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    // Start the initial frame + async
    await tester.pump();       // builds loading
    await tester.pump(const Duration(milliseconds: 10)); // completes fetch
    await tester.pumpAndSettle();
  }

  testWidgets('loading => shows CircularProgressIndicator', (tester) async {
    // Use a service that never completes to force loading
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          patientServiceProvider.overrideWithValue(
            FakePatientService(List.empty()),
          )
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    // Immediately after first pump, loading is in progress
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('empty => shows "No patients found."', (tester) async {
    await pumpPatientScreen(tester, []);
    expect(find.text('No patients found.'), findsOneWidget);
  });

  testWidgets('data => renders PatientCard entries', (tester) async {
    final p1 = PatientProfile(
      id: 1,
      name: 'Alice',
      relative: null,
      dateOfBirth: '1990-01-01',
      gender: 'F',
      weight: null,
      height: null,
      bloodType: null,
      phoneNumber: null,
      patientId: 'P001',
      email: 'alice@example.com',
    );
    final p2 = PatientProfile(
      id: 2,
      name: 'Bob',
      relative: null,
      dateOfBirth: '1985-05-05',
      gender: 'M',
      weight: null,
      height: null,
      bloodType: null,
      phoneNumber: null,
      patientId: 'P002',
      email: 'bob@example.com',
    );

    await pumpPatientScreen(tester, [p1, p2]);

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('ID: P001'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('ID: P002'), findsOneWidget);
  });

  testWidgets('search filters the list', (tester) async {
    final p1 = PatientProfile(
      id: 1,
      name: 'Carol',
      relative: null,
      dateOfBirth: '1992-02-02',
      gender: 'F',
      weight: null,
      height: null,
      bloodType: null,
      phoneNumber: null,
      patientId: 'C001',
      email: 'carol@example.com',
    );
    final p2 = PatientProfile(
      id: 2,
      name: 'Dave',
      relative: null,
      dateOfBirth: '1993-03-03',
      gender: 'M',
      weight: null,
      height: null,
      bloodType: null,
      phoneNumber: null,
      patientId: 'D002',
      email: 'dave@example.com',
    );
    await pumpPatientScreen(tester, [p1, p2]);

    // Both visible initially
    expect(find.text('Carol'), findsOneWidget);
    expect(find.text('Dave'), findsOneWidget);

    // Enter search text
    await tester.enterText(find.byType(TextField), 'Dav');
    await tester.pumpAndSettle();

    // Only Dave remains
    expect(find.text('Carol'), findsNothing);
    expect(find.text('Dave'), findsOneWidget);
  });

  testWidgets('tapping + shows register dialog', (tester) async {
    await pumpPatientScreen(tester, []);
    // Tap the add icon
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterCreateProfileDialog), findsOneWidget);
  });
}
