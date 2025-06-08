import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../provider/upload_provider.dart';
import '../service/upload_service.dart';

class UploadLabReportNotifier extends AsyncNotifier<String> {
  late final LabReportService _service;

  @override
  Future<String> build() async {
    _service = ref.watch(labReportServiceProvider);
    return ''; // initial state data can be empty string
  }

  Future<void> upload({
    required PlatformFile platformFile,
    required String patientId,
    required String testType,
  }) async {
    state = const AsyncValue.loading();
    try {
      final uploadMsg = await _service.uploadLabReport(
        platformFile: platformFile,
        patientId: patientId,
        testType: testType,
      );

      final sendMsg = await _service.sendToPatient(patientId);

      state = AsyncValue.data("✅ $uploadMsg\n✅ $sendMsg");
    } catch (e, st) {
      state = AsyncValue.error("❌ Failed: $e", st);
    }
  }
}

// Provider for notifier
final uploadLabReportProvider =
    AsyncNotifierProvider<UploadLabReportNotifier, String>(
  UploadLabReportNotifier.new,
);
