import 'package:flutter_riverpod/flutter_riverpod.dart';
import "../../../../core/api/api_client.dart";
import "../service/upload_service.dart";

// Provide the ApiClient
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Provide the LabReportService, dependent on ApiClient
final labReportServiceProvider = Provider<LabReportService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LabReportService(apiClient);
});
