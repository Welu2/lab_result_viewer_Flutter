import '../../../core/api/api_client.dart';
import '../models/lab_result.dart';
import 'package:dio/dio.dart';

class LabResultsService {
  final ApiClient _apiClient;
  LabResultsService(this._apiClient);

  Future<List<LabResult>> fetchLabResults() async {
    final response = await _apiClient.get('/lab-results');
    final List data = response.data as List;
    return data.map((e) => LabResult.fromJson(e)).toList();
  }

  String getDownloadUrl(int labResultId) {
    final baseUrl = ApiClient.baseUrl.endsWith('/') 
        ? ApiClient.baseUrl.substring(0, ApiClient.baseUrl.length - 1)
        : ApiClient.baseUrl;
    return '$baseUrl/lab-results/download/$labResultId';
  }

  Future<Response> downloadLabResult(int labResultId) async {
    final url = getDownloadUrl(labResultId);
    return await _apiClient.dio.get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
  }
} 