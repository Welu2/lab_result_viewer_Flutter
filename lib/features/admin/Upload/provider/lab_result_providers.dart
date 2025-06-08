import 'package:flutter_riverpod/flutter_riverpod.dart';
import "../../../../core/api/api_client.dart";
import "../service/lab_result_service.dart";
import "../model/lab_model.dart";

/// Provides a singleton ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provides LabResultService using the ApiClient
final labServiceProvider = Provider<LabService>((ref) {
  final api = ref.watch(apiClientProvider);
  return LabService(api);
});

/// Fetches all lab results (admin only)
final labResultsProvider = FutureProvider<List<LabResult>>((ref) async {
  final service = ref.watch(labServiceProvider);
  return service.getAllLabResults();
});

/// Provider to delete a lab result by id
final deleteLabResultProvider = Provider<Future<void> Function(int)>((ref) {
  final service = ref.watch(labServiceProvider);
  return (int id) async {
    await service.deleteLabResult(id);
    ref.invalidate(labResultsProvider); // Refresh after deletion
  };
});
