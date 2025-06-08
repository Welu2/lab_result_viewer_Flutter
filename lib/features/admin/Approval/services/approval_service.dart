import '../../../../core/api/api_client.dart';
import '../models/approval_model.dart';

class AppointmentsService {
  final ApiClient _apiClient;

  AppointmentsService(this._apiClient);

  Future<List<Appointment>> fetchAllAppointments() async {
    final response = await _apiClient.get('/appointments');
    return (response.data as List)
        .map((json) => Appointment.fromJson(json))
        .toList();
  }

  Future<List<Appointment>> fetchPendingAppointments() async {
    final response = await _apiClient.get(
      '/appointments',
      queryParameters: {'status': 'pending'},
    );
    return (response.data as List)
        .map((json) => Appointment.fromJson(json))
        .toList();
  }

  Future<void> approve(int id) async {
    await _apiClient
        .patch('/appointments/$id/status', data: {'status': 'confirmed'});
  }

  Future<void> decline(int id) async {
    await _apiClient
        .patch('/appointments/$id/status', data: {'status': 'disapproved'});
  }
}
