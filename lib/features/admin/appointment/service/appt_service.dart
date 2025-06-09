import "../../../../core/api/api_client.dart";
import "../../Approval/models/approval_model.dart";

class AppointmentService {
  final ApiClient api;

  AppointmentService(this.api);

  Future<List<Appointment>> getMyAppointments() async {
   final response = await api.get('/appointments', queryParameters: {
      'status': 'confirmed',
    });
    final List data = response.data;
    return data.map((json) => Appointment.fromJson(json)).toList();
  }
}
