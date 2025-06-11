import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lab_result_viewer/features/admin/Upload/provider/lab_result_providers.dart';
import 'package:lab_result_viewer/features/admin/Patient/Provider/patient_provider.dart';
import 'package:lab_result_viewer/features/admin/Upload/model/lab_model.dart';
import 'package:lab_result_viewer/features/admin/Patient/model/patient_profile.dart';
import 'package:lab_result_viewer/features/admin/Upload/screen/lab_screen.dart';

void main() {
  final lab1 = LabResult(
    id: 1,
    title: 'Blood Test',
    description: 'desc',
    filePath: '/path/a.pdf',
    isSent: true,
    createdAt: '2025-06-01T12:00:00Z',
    patientId: 'p1',
    patientName: 'Alice Smith',
  );
  final lab2 = LabResult(
    id: 2,
    title: 'X-Ray Scan',
    description: 'desc',
    filePath: '/path/b.pdf',
    isSent: false,
    createdAt: '2025-06-02T15:30:00Z',
    patientId: 'p2',
    patientName: 'Bob Jones',
  );

  final patient1 = PatientProfile(
    id: 101,
    name: 'Alice Smith',
    relative: null,
    dateOfBirth: '1990-01-01',
    gender: 'F',
    weight: 60.0,
    height: 165.0,
    bloodType: 'A+',
    phoneNumber: '1234',
    patientId: 'p1',
    email: 'alice@example.com',
  );
  final patient2 = PatientProfile(
    id: 102,
    name: 'Bob Jones',
    relative: null,
    dateOfBirth: '1985-05-05',
    gender: 'M',
    weight: 75.0,
    height: 180.0,
    bloodType: 'B+',
    phoneNumber: '5678',
    patientId: 'p2',
    email: 'bob@example.com',
  );

  /// Pumps the LabResultListScreen with test-specific futures.
  Future<void> _build(
    WidgetTester tester, {
    required Future<List<LabResult>> labFuture,
    required Future<List<PatientProfile>> patFuture,
    GoRouter? router,
  }) async {
    router ??= GoRouter(
      initialLocation: '/admin-upload',
      routes: [
        GoRoute(path: '/admin-upload', builder: (_, __) => const LabResultListScreen()),
      ],
    );

    // Create override providers for the futures:
    final labProviderOverride = FutureProvider<List<LabResult>>((ref) => labFuture);
    final patProviderOverride = FutureProvider<List<PatientProfile>>((ref) => patFuture);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          labResultsProvider.overrideWithProvider(labProviderOverride),
          fetchAllPatientsProvider.overrideWithProvider(patProviderOverride),
          deleteLabResultProvider.overrideWithValue((int id) async {}),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  testWidgets('shows loading indicator when lab results are loading', (tester) async {
    final completer = Completer<List<LabResult>>();

    await _build(
      tester,
      labFuture: completer.future,
      patFuture: Future.value([]),
    );

    await tester.pump(); // start build

    // With the future still pending, we should see the loading spinner:
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the future to let the screen settle:
    completer.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('shows message when no lab results are available', (tester) async {
    await _build(
      tester,
      labFuture: Future.value([]),
      patFuture: Future.value([]),
    );
    await tester.pumpAndSettle();
    expect(find.text('No lab results found.'), findsOneWidget);
  });

  testWidgets('renders lab results with associated patient names', (tester) async {
    await _build(
      tester,
      labFuture: Future.value([lab1, lab2]),
      patFuture: Future.value([patient1, patient2]),
    );
    await tester.pumpAndSettle();

    // Both patient names should appear
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('id: p1'), findsOneWidget);
    expect(find.text('Blood Test'), findsOneWidget);

    expect(find.text('Bob Jones'), findsOneWidget);
    expect(find.text('id: p2'), findsOneWidget);
    expect(find.text('X-Ray Scan'), findsOneWidget);
  });

  testWidgets('navigates to upload page on "Upload Report" button tap', (tester) async {
    bool navigated = false;
    final uploadRouter = GoRouter(
      initialLocation: '/admin-upload',
      routes: [
        GoRoute(path: '/admin-upload', builder: (_, __) => const LabResultListScreen()),
        GoRoute(path: '/upload', builder: (_, __) {
          navigated = true;
          return const Scaffold(body: Text('Upload Page'));
        }),
      ],
    );

    await _build(
      tester,
      labFuture: Future.value([lab1]),
      patFuture: Future.value([patient1]),
      router: uploadRouter,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Upload Report'));
    await tester.pumpAndSettle();
    expect(navigated, isTrue);
  });

  testWidgets('shows confirmation dialog when delete is selected', (tester) async {
    await _build(
      tester,
      labFuture: Future.value([lab1]),
      patFuture: Future.value([patient1]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();

    expect(find.text('Delete Lab Result'), findsOneWidget);
    expect(find.text('Are you sure you want to delete this lab result?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });
}
