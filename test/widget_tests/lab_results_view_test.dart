import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_result_viewer/features/lab_results/widgets/lab_results_view.dart';
import 'package:lab_result_viewer/features/lab_results/models/lab_result.dart';


// test/widget/lab_results_view_test.dart


void main() {
  Future<void> _pumpView(
    WidgetTester tester, {
    required bool isLoading,
    String? error,
    required List<LabResult> results,
    required Function(LabResult) onView,
    required Function(LabResult) onDownload,
    required Function(LabResult) onCopyLink,
    required Function(LabResult) onDownloadPdf,
    int? downloadingId,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LabResultsView(
            isLoading: isLoading,
            error: error,
            results: results,
            downloadingId: downloadingId,
            onView: onView,
            onDownload: onDownload,
            onCopyLink: onCopyLink,
            onDownloadPdf: onDownloadPdf,
          ),
        ),
      ),
    );
  }

  testWidgets('loading => shows a centered spinner', (tester) async {
    await _pumpView(
      tester,
      isLoading: true,
      error: null,
      results: [],
      onView: (_) {},
      onDownload: (_) {},
      onCopyLink: (_) {},
      onDownloadPdf: (_) {},
      downloadingId: null,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('error => shows error text', (tester) async {
    await _pumpView(
      tester,
      isLoading: false,
      error: 'Network failure',
      results: [],
      onView: (_) {},
      onDownload: (_) {},
      onCopyLink: (_) {},
      onDownloadPdf: (_) {},
      downloadingId: null,
    );
    expect(find.text('Error: Network failure'), findsOneWidget);
  });

  testWidgets('empty => shows no lab results message', (tester) async {
    await _pumpView(
      tester,
      isLoading: false,
      error: null,
      results: [],
      onView: (_) {},
      onDownload: (_) {},
      onCopyLink: (_) {},
      onDownloadPdf: (_) {},
      downloadingId: null,
    );
    expect(find.text('No lab results found.'), findsOneWidget);
  });

  group('with results', () {
    final lab = LabResult(
      id: 42,
      title: 'CBC',
      reportDate: '2025-06-10',
      reportType: 'Blood Work',
      status: 'normal',
      downloadUrl: 'http://example.com/42.pdf',
    );

    testWidgets('renders a LabResultCard for each result', (tester) async {
      await _pumpView(
        tester,
        isLoading: false,
        error: null,
        results: [lab],
        onView: (_) {},
        onDownload: (_) {},
        onCopyLink: (_) {},
        onDownloadPdf: (_) {},
        downloadingId: null,
      );
      // Title
      expect(find.text('CBC'), findsOneWidget);
      // Report date
      expect(find.text('2025-06-10'), findsOneWidget);
      // Report type
      expect(find.text('Blood Work'), findsOneWidget);
      // Status text
      expect(find.text('Normal Results'), findsOneWidget);
      // View and Download buttons
      expect(find.text('View Report'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
      // Share icon
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    });

    testWidgets('download indicator shows when downloadingId matches', (tester) async {
      await _pumpView(
        tester,
        isLoading: false,
        error: null,
        results: [lab],
        onView: (_) {},
        onDownload: (_) {},
        onCopyLink: (_) {},
        onDownloadPdf: (_) {},
        downloadingId: 42,
      );
      await tester.pump(const Duration(milliseconds: 100)); // one frame

      // The 'View Report' button is replaced by a small spinner
      expect(
        find.byWidgetPredicate((w) =>
          w is SizedBox &&
          w.child is CircularProgressIndicator
        ),
        findsOneWidget,
      );
    });

    testWidgets('share dialog Copy Link & Download PDF callbacks', (tester) async {
      bool copyCalled = false, pdfCalled = false;
      await _pumpView(
        tester,
        isLoading: false,
        error: null,
        results: [lab],
        onView: (_) {},
        onDownload: (_) {},
        onCopyLink: (_) => copyCalled = true,
        onDownloadPdf: (_) => pdfCalled = true,
        downloadingId: null,
      );
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pumpAndSettle();

      // Copy Link
      await tester.tap(find.text('Copy Link'));
      await tester.pumpAndSettle();
      expect(copyCalled, isTrue);

      // Re-open and Download PDF
      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Download PDF'));
      await tester.pumpAndSettle();
      expect(pdfCalled, isTrue);
    });
  });
}
