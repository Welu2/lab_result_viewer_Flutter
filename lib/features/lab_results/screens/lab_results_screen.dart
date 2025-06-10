import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab_result_viewer/core/services/file_service.dart';
import 'package:lab_result_viewer/features/appointments_user/notifiers/appointment_notifier.dart';
import '../widgets/lab_results_view.dart';
import '../providers/lab_results_provider.dart';
import '../models/lab_result.dart'; // Import your LabResult model

class LabResultsScreen extends ConsumerStatefulWidget {
  const LabResultsScreen({super.key});
  @override
  ConsumerState<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends ConsumerState<LabResultsScreen> {
  int? _downloadingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(labResultsProvider.notifier).fetchLabResults();
    });
  }

  void _onCopyLink(int resultId) {
    final url = ref.read(labResultsServiceProvider).getDownloadUrl(resultId);
    ref.read(fileServiceProvider).copyToClipboard(url);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download link copied to clipboard!')),
    );
  }

  // --- FIX 2: This method now correctly takes the whole LabResult object ---
  Future<void> _onDownloadOrView(LabResult result) async {
    setState(() {
      _downloadingId = result.id;
    });

    final fileService = ref.read(fileServiceProvider);
    final labResultsService = ref.read(labResultsServiceProvider);
    // This will now work because of the import we added
    final dio = ref.read(apiClientProvider).dio; 
    final url = labResultsService.getDownloadUrl(result.id);
    
    // Provide a default title if the real one is null
    final safeTitle = result.title ?? 'report';
    final fileName = "lab_result_${safeTitle.replaceAll(' ', '_')}_${result.id}.pdf";

    final savedPath = await fileService.downloadAndSaveFile(url, fileName, dio);

    setState(() {
      _downloadingId = null;
    });

    if (savedPath != null) {
      await fileService.openFile(savedPath);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(labResultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lab Results')),
      body: LabResultsView(
        isLoading: state.isLoading,
        error: state.error,
        results: state.labResults,
        downloadingId: _downloadingId,
        onCopyLink: (result) => _onCopyLink(result.id),
        onDownloadPdf: (result) => _onDownloadOrView(result),
        onView: (result) => _onDownloadOrView(result),
        onDownload: (result) => _onDownloadOrView(result),
      ),
    );
  }
}