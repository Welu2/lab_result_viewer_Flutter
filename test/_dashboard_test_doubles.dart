import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab_result_viewer/features/admin/Dashboard/provider/dashboard_provider.dart';
import 'package:lab_result_viewer/features/admin/Dashboard/model/dashboard_model.dart';
import 'package:lab_result_viewer/features/admin/Dashboard/service/dashboard_service.dart';

// 1a) Fake service that always returns our fake stats (or delays to simulate loading)
class FakeDashboardService implements DashboardService {
  final DashboardStats stats;
  FakeDashboardService(this.stats);

  @override
  Future<DashboardStats> fetchDashboard() async {
    return stats;
  }
}

// 1b) A helper that builds a provider returning a notifier seeded with a given state
StateNotifierProvider<DashboardNotifier, DashboardState> makeFakeDashboardProvider(
    DashboardState initialState) {
  return StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
    // We won't actually call fetchDashboard, so service can be anything.
    final fakeService = FakeDashboardService(initialState.stats ?? DashboardStats(
      totalAppointments: 0,
      totalPatients: 0,
      totalLabResults: 0,
      upcomingAppointments: [],
    ));
    final notifier = DashboardNotifier(fakeService);

    // Override the notifier's state to exactly what we want.
    notifier.state = initialState;
    return notifier;
  });
}
