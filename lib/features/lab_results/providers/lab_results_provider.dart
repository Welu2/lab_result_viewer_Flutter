import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lab_result.dart';
import '../services/lab_results_service.dart';

final labResultsServiceProvider = Provider<LabResultsService>((ref) {
  throw UnimplementedError('LabResultsService must be provided');
});

final labResultsProvider = StateNotifierProvider<LabResultsNotifier, LabResultsState>((ref) {
  final labResultsService = ref.watch(labResultsServiceProvider);
  return LabResultsNotifier(labResultsService);
});

class LabResultsState {
  final List<LabResult> labResults;
  final bool isLoading;
  final String? error;

  LabResultsState({
    this.labResults = const [],
    this.isLoading = false,
    this.error,
  });

  LabResultsState copyWith({
    List<LabResult>? labResults,
    bool? isLoading,
    String? error,
  }) {
    return LabResultsState(
      labResults: labResults ?? this.labResults,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class LabResultsNotifier extends StateNotifier<LabResultsState> {
  final LabResultsService _service;

  LabResultsNotifier(this._service) : super(LabResultsState());

  Future<void> fetchLabResults() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _service.fetchLabResults();
      state = state.copyWith(
        isLoading: false,
        labResults: results,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
} 