import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_result_viewer/features/lab_results/widgets/lab_results_view.dart';
import 'package:lab_result_viewer/features/lab_results/models/lab_result.dart';

void main() {
  final sample = LabResult(
    id: 1,
    title: 'Blood Test',
    reportDate: '2025-06-01',
    status: 'normal',
  );

  testWidgets('shows loading spinner', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LabResultsView(
          isLoading: true,
          error: null,
          results: [],
          onShare: (_) {},
          onOpen: (_) {},
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LabResultsView(
          isLoading: false,
          error: 'Failed to load',
          results: [],
          onShare: (_) {},
          onOpen: (_) {},
        ),
      ),
    );
    expect(find.text('Error: Failed to load'), findsOneWidget);
  });

  testWidgets('shows empty placeholder', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LabResultsView(
          isLoading: false,
          error: null,
          results: [],
          onShare: (_) {},
          onOpen: (_) {},
        ),
      ),
    );
    expect(find.text('No Lab Results Found'), findsOneWidget);
    expect(find.text('No results match your filters'), findsOneWidget);
  });

  testWidgets('renders list of LabResultCards and handles taps',
      (tester) async {
    LabResult? shared, opened;

    await tester.pumpWidget(MaterialApp(
      home: LabResultsView(
        isLoading: false,
        error: null,
        results: [sample],
        onShare: (r) => shared = r,
        onOpen: (r) => opened = r,
      ),
    ));

    // Title, date, status text
    expect(find.text('Blood Test'), findsOneWidget);
    expect(find.text('2025-06-01'), findsOneWidget);
    expect(find.text('Normal Results'), findsOneWidget);

    // Share button
    final shareBtn = find.byIcon(Icons.share_outlined);
    expect(shareBtn, findsOneWidget);
    await tester.tap(shareBtn);
    expect(shared, sample);

    // View Report
    final viewBtn = find.widgetWithText(ElevatedButton, 'View Report');
    await tester.tap(viewBtn);
    expect(opened, sample);

    // Download button
    final downloadBtn = find.widgetWithText(OutlinedButton, 'Download');
    await tester.tap(downloadBtn);
    expect(opened, sample);
  });
}
