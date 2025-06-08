import '../../../../core/api/api_client.dart';
import '../model/dashboard_model.dart';
import 'dart:async';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  Future<DashboardStats> fetchDashboard() async {
    try {
      final response = await _apiClient
          .get('/admin/dashboard')
          .timeout(const Duration(seconds: 10)); // ⏱️ Timeout here

      print('✅ Dashboard API Response: ${response.data}');
      return DashboardStats.fromJson(response.data);
    } on TimeoutException catch (e) {
      print('⏱️ Dashboard request timed out: $e');
      throw Exception("Dashboard request timed out. Please try again.");
    } catch (e) {
      print('❌ Dashboard Fetch Error: $e');
      throw Exception("Failed to fetch dashboard data.");
    }
  }
}
