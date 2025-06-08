import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../services/approval_service.dart';

/// Provide the ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provide AppointmentService with ApiClient injected
final appointmentsServiceProvider = Provider<AppointmentsService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AppointmentsService(apiClient);
});
