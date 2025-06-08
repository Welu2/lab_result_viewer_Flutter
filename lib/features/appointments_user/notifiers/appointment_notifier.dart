import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../../../core/api/api_client.dart';
import '../../../features/notifications/providers/notification_provider.dart';

// Provide the API client
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return AppointmentService(apiClient, notificationService);
});

class AppointmentNotifier extends StateNotifier<List<Appointment>> {
  AppointmentNotifier(this._service) : super([]);
  final AppointmentService _service;

  Future<void> loadUserAppointments() async {
    try {
      final appointments = await _service.fetchUserAppointments();
      state = appointments;
    } catch (e) {
      print('Error loading appointments: $e');
      // Consider adding a way to notify the UI about the error
      // For now, rethrow to let the UI handle it or for further debugging.
      rethrow;
    }
  }

  Future<void> bookAppointment(String testType, String date, String time) async {
    try {
      final newAppointment = await _service.bookAppointment(testType, date, time);
      state = [...state, newAppointment];
    } catch (e) {
      print('Error booking appointment: $e');
      rethrow;
    }
  }

  Future<void> updateAppointment(String id, String testType, String date, String time) async {
    try {
      final updatedAppointment = await _service.updateAppointment(id, testType, date, time);
      state = state.map((appt) => appt.id == id ? updatedAppointment : appt).toList();
    } catch (e) {
      print('Error updating appointment: $e');
      rethrow;
    }
  }

  Future<void> deleteAppointment(String id) async {
    try {
      final success = await _service.deleteAppointment(id);
      if (success) {
        state = state.where((appt) => appt.id != id).toList();
      }
    } catch (e) {
      print('Error deleting appointment: $e');
      rethrow;
    }
  }

  Future<void> approveAppointment(String id, String userId) async {
    try {
      final approvedAppointment = await _service.approveAppointment(id, userId);
      state = state.map((appt) => appt.id == id ? approvedAppointment : appt).toList();
    } catch (e) {
      print('Error approving appointment: $e');
      rethrow;
    }
  }
}

final appointmentNotifierProvider = StateNotifierProvider<AppointmentNotifier, List<Appointment>>(
  (ref) => AppointmentNotifier(ref.read(appointmentServiceProvider)),
);
