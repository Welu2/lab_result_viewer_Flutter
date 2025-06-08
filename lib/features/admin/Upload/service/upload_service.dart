import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import "../../../../core/api/api_client.dart";

class LabReportService {
  final ApiClient _api;

  LabReportService(this._api);

  Future<String> uploadLabReport({
    required PlatformFile platformFile,
    required String patientId,
    required String testType,
  }) async {
    if (platformFile.bytes == null) {
      throw Exception("File bytes are null. Cannot upload file.");
    }

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        platformFile.bytes!,
        filename: platformFile.name,
      ),
      'testType': testType,
    });

    final response =
        await _api.post('/lab-results/upload/$patientId', data: formData);

    if (response.data == null || response.data['message'] == null) {
      return 'Uploaded.';
    }
    return response.data['message'];
  }


  Future<String> sendToPatient(String patientId) async {
    final response = await _api.post('/lab-results/send/$patientId');
    return response.data['message'] ?? 'Sent.';
  }
}
