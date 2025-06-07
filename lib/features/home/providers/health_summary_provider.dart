import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

final healthSummaryServiceProvider = Provider<HealthSummaryService>((ref) {
  throw UnimplementedError('HealthSummaryService must be provided');
});

final healthSummaryProvider = StateNotifierProvider<HealthSummaryNotifier, HealthSummaryState>((ref) {
  final healthSummaryService = ref.watch(healthSummaryServiceProvider);
  return HealthSummaryNotifier(healthSummaryService);
});

class HealthSummaryState {
  final int totalTests;
  final int abnormalResults;
  final bool isLoading;
  final String? error;

  HealthSummaryState({
    this.totalTests = 0,
    this.abnormalResults = 0,
    this.isLoading = false,
    this.error,
  });

  HealthSummaryState copyWith({
    int? totalTests,
    int? abnormalResults,
    bool? isLoading,
    String? error,
  }) {
    return HealthSummaryState(
      totalTests: totalTests ?? this.totalTests,
      abnormalResults: abnormalResults ?? this.abnormalResults,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class HealthSummaryService {
  final ApiClient _apiClient;

  HealthSummaryService(this._apiClient);

  Future<Map<String, dynamic>> fetchSummary() async {
    final response = await _apiClient.get('/lab-results/summary');
    return response.data;
  }
}

class HealthSummaryNotifier extends StateNotifier<HealthSummaryState> {
  final HealthSummaryService _service;

  HealthSummaryNotifier(this._service) : super(HealthSummaryState());

  Future<void> fetchSummary() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.fetchSummary();
      state = state.copyWith(
        isLoading: false,
        totalTests: data['totalTests'] ?? 0,
        abnormalResults: 0, // Static for now
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
} 