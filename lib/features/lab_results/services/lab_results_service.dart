import '../../../core/api/api_client.dart';
import '../models/lab_result.dart';

class LabResultsService {
  final ApiClient _apiClient;
  LabResultsService(this._apiClient);

  Future<List<LabResult>> fetchLabResults() async {
    final response = await _apiClient.get('/lab-results');
    final List data = response.data as List;
    return data.map((e) => LabResult.fromJson(e)).toList();
  }

  String getDownloadUrl(int labResultId) {
    return '${ApiClient.baseUrl}/lab-results/download/$labResultId';
  }
} 