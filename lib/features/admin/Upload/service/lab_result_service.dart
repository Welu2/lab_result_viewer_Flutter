import "../../../../core/api/api_client.dart";
import "../model/lab_model.dart";

class LabService {
  final ApiClient api;

  LabService(this.api);

  Future<List<LabResult>> getAllLabResults() async {
    final response = await api.get('/lab-results/admin');
    return (response.data as List)
        .map((json) => LabResult.fromJson(json))
        .toList();
  }

  Future<void> deleteLabResult(int id) async {
    await api.delete('/lab-results/$id');
  }
}
