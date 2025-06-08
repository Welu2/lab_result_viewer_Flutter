import 'package:flutter_riverpod/flutter_riverpod.dart';
import "../../Approval/models/approval_model.dart";
import "../service/appt_service.dart";
import "../../../../core/api/api_client.dart";

// Provide the API client
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Provide the appointment service
final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  final api = ref.read(apiClientProvider);
  return AppointmentService(api);
});

// Provide appointments based on filter: today, upcoming, past
final appointmentsProvider =
    FutureProvider.family<List<Appointment>, String>((ref, filter) async {
  final service = ref.read(appointmentServiceProvider);
  final all = await service.getMyAppointments();
  final now = DateTime.now();

  if (filter == 'today') {
    return all.where((a) {
      final date = DateTime.parse(a.date);
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();
  } else if (filter == 'upcoming') {
    return all.where((a) => DateTime.parse(a.date).isAfter(now)).toList();
  } else if (filter == 'past') {
    return all.where((a) => DateTime.parse(a.date).isBefore(now)).toList();
  }

  return all;
});
