import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/dashboard_model.dart';
import '../service/dashboard_service.dart';
import '../../../../core/api/api_client.dart';

// Provider for the service
final dashboardServiceProvider = Provider<DashboardService>(
  (ref) => DashboardService(ApiClient()),
);

// Dashboard state
class DashboardState {
  final bool isLoading;
  final String? error;
  final DashboardStats? stats;
  final bool hasFetched;

  DashboardState({
    this.isLoading = false,
    this.error,
    this.stats,
    this.hasFetched = false,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    DashboardStats? stats,
    bool? hasFetched,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error, // Preserve error if not overridden
      stats: stats ?? this.stats,
      hasFetched: hasFetched ?? this.hasFetched,
    );
  }
}

// StateNotifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardService _dashboardService;

  DashboardNotifier(this._dashboardService) : super(DashboardState());

  Future<void> fetchDashboard() async {
    if (state.hasFetched) {
      print('Dashboard data already fetched, skipping fetch.');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final stats = await _dashboardService.fetchDashboard();
      

      if (stats == null) {
        print('Warning: dashboard stats is null!');
      }

      state = state.copyWith(
        stats: stats,
        isLoading: false,
        hasFetched: true,
        error: null,
      );
    } catch (e, st) {
      
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        hasFetched: true,
      );
    }
  }

  void refreshDashboard() {
    state = DashboardState(); // Reset state
    fetchDashboard(); // Fetch again
  }
}

// StateNotifierProvider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final service = ref.read(dashboardServiceProvider);
  return DashboardNotifier(service);
});
