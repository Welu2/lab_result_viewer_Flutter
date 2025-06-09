import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/approval_model.dart';
import '../services/approval_service.dart';
import "approval_provider.dart";


class AppointmentNotifier extends AsyncNotifier<List<Appointment>> {
  late final AppointmentsService _service;

  @override
  Future<List<Appointment>> build() async {
    _service = ref.read(appointmentsServiceProvider);
    return fetchPending(); // Initial fetch
  }

  Future<List<Appointment>> fetchPending() async {
    try {
      final appointments = await _service.fetchPendingAppointments();
      state = AsyncData(appointments);
      return appointments;
    } catch (e, st) {
      state = AsyncError(e, st);
      return [];
    }
  }

  Future<void> approve(int id) async {
    try {
      await _service.approve(id);
      
      await fetchPending(); // Refresh pending appointments list
    } catch (e) {
    
    }
  }

  Future<void> decline(int id) async {
    try {
      await _service.decline(id);
      await fetchPending(); // Refresh pending appointments list
    } catch (e) {
      
    }
  }
}

/// Riverpod provider
final appointmentNotifierProvider =
    AsyncNotifierProvider<AppointmentNotifier, List<Appointment>>(
        AppointmentNotifier.new);

final hasPendingAppointmentsProvider = Provider<bool>((ref) {
  final state = ref.watch(appointmentNotifierProvider);

  return state.when(
    data: (appointments) => appointments.any((a) => a.status == 'pending'),
    loading: () => false,
    error: (_, __) => false,
  );
});
