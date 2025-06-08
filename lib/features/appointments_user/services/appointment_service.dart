import 'dart:async';
import '../models/appointment.dart';
import '../../../core/api/api_client.dart';
import '../../../features/notifications/services/notification_service.dart';

class AppointmentService {
  final ApiClient _apiClient;
  final NotificationService _notificationService;

  AppointmentService(this._apiClient, this._notificationService);

  Future<List<Appointment>> fetchUserAppointments() async {
    try {
      final response = await _apiClient.get('/appointments/me');
      print('Raw API response for user appointments: ${response.data}');
      if (response.data == null) return [];
      final List data = response.data as List;
      return data.map((e) {
        try {
          return Appointment.fromJson(e);
        } catch (parseError) {
          print('Error parsing appointment JSON: $parseError, Data: $e');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('Error fetching appointments in service: $e');
      rethrow;
    }
  }

  Future<Appointment> bookAppointment(String testType, String date, String time) async {
    try {
      final response = await _apiClient.post('/appointments', data: {
        'testType': testType,
        'date': date,
        'time': time,
        'status': 'pending',
      });

      final appointment = Appointment.fromJson(response.data);
      
      // Send notification to admin
      await _apiClient.post('/notifications/admin', data: {
        'message': 'New appointment request for $testType on $date at $time',
        'type': 'appointment',
        'recipientType': 'admin',
        'appointmentId': appointment.id,
      });

      return appointment;
    } catch (e) {
      print('Error booking appointment: $e');
      rethrow;
    }
  }

  Future<Appointment> updateAppointment(String id, String testType, String date, String time) async {
    try {
      final response = await _apiClient.put('/appointments/$id', data: {
        'testType': testType,
        'date': date,
        'time': time,
      });

      final appointment = Appointment.fromJson(response.data);
      
      // Send notification to admin about rescheduling
      await _apiClient.post('/notifications/admin', data: {
        'message': 'Appointment rescheduled for $testType on $date at $time',
        'type': 'appointment',
        'recipientType': 'admin',
        'appointmentId': appointment.id,
      });

      return appointment;
    } catch (e) {
      print('Error updating appointment: $e');
      rethrow;
    }
  }

  Future<bool> deleteAppointment(String id) async {
    try {
      await _apiClient.delete('/appointments/$id');
      return true;
    } catch (e) {
      print('Error deleting appointment: $e');
      rethrow;
    }
  }

  Future<Appointment> approveAppointment(String id, String userId) async {
    try {
      final response = await _apiClient.put('/appointments/$id/approve', data: {
        'status': 'approved',
      });

      final appointment = Appointment.fromJson(response.data);
      
      // Send notification to user about approval
      await _apiClient.post('/notifications/user', data: {
        'message': 'Your appointment for ${appointment.testType} on ${appointment.date} at ${appointment.time} has been approved',
        'type': 'appointment',
        'recipientType': 'user',
        'patientId': userId,
        'appointmentId': appointment.id,
      });

      return appointment;
    } catch (e) {
      print('Error approving appointment: $e');
      rethrow;
    }
  }
}
