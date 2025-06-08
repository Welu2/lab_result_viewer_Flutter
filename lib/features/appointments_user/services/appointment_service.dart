import 'dart:async';
import '../models/appointment.dart';

class AppointmentService {
  final List<Appointment> _inMemory = [];

  Future<List<Appointment>> fetchUserAppointments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_inMemory);
  }

  Future<bool> bookAppointment(String testType, String date, String time) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newAppt = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      testType: testType,
      date: date,
      time: time,
      status: 'pending',
    );
    _inMemory.add(newAppt);
    return true;
  }

  Future<bool> updateAppointment(String id, String testType, String date, String time) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _inMemory.indexWhere((appt) => appt.id == id);
    if (idx == -1) return false;
    final existingStatus = _inMemory[idx].status;
    _inMemory[idx] = Appointment(
      id: id,
      testType: testType,
      date: date,
      time: time,
      status: existingStatus,
    );
    return true;
  }

  Future<bool> deleteAppointment(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final before = _inMemory.length;
    _inMemory.removeWhere((appt) => appt.id == id);
    return _inMemory.length < before;
  }
}
