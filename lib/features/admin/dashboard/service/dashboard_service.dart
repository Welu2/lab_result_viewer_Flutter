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

    
      return DashboardStats.fromJson(response.data);
    } on TimeoutException catch (e) {
      
      throw Exception("Dashboard request timed out. Please try again.");
    } catch (e) {
     
      throw Exception("Failed to fetch dashboard data.");
    }
  }
}
