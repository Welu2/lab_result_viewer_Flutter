import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';

final appointmentServiceProvider = Provider<AppointmentService>((ref) => AppointmentService());

class AppointmentNotifier extends StateNotifier<List<Appointment>> {
  AppointmentNotifier(this._service) : super([]);
  final AppointmentService _service;

  Future<void> loadUserAppointments() async {
    state = await _service.fetchUserAppointments();
  }

  Future<bool> bookAppointment(String testType, String date, String time) async {
    final success = await _service.bookAppointment(testType, date, time);
    if (success) state = await _service.fetchUserAppointments();
    return success;
  }

  Future<bool> updateAppointment(String id, String testType, String date, String time) async {
    final success = await _service.updateAppointment(id, testType, date, time);
    if (success) state = await _service.fetchUserAppointments();
    return success;
  }

  Future<bool> deleteAppointment(String id) async {
    final success = await _service.deleteAppointment(id);
    if (success) state = state.where((a) => a.id != id).toList();
    return success;
  }
}

final appointmentNotifierProvider = StateNotifierProvider<AppointmentNotifier, List<Appointment>>(
  (ref) => AppointmentNotifier(ref.read(appointmentServiceProvider)),
);
