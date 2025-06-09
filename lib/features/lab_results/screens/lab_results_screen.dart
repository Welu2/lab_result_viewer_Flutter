// lib/app/lab_results/screens/lab_results_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/lab_results_view.dart';
import '../providers/lab_results_provider.dart';

class LabResultsScreen extends ConsumerStatefulWidget {
  const LabResultsScreen({super.key});
  @override
  ConsumerState<LabResultsScreen> createState() =>
      _LabResultsScreenState();
}

class _LabResultsScreenState extends ConsumerState<LabResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(labResultsProvider.notifier).fetchLabResults();
    });
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
        onShare: (r) {
          // existing share logic
        },
        onOpen: (r) {
          // existing download logic
        },
      ),
    );
  }
}
