import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:lab_result_viewer/core/api/api_client.dart';
import 'package:lab_result_viewer/features/lab_results/models/lab_result.dart';
import 'package:lab_result_viewer/features/lab_results/services/lab_results_service.dart';

import 'lab_results_service_test.mocks.dart';

@GenerateMocks([ApiClient])

void main() {
  late LabResultsService labResultsService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    labResultsService = LabResultsService(mockApiClient);
  });

  group('LabResultsService', () {
    final mockLabResultJson = {
      'id': 1,
      'title': 'Blood Test',
      'description': 'Blood Test Description',
      'filePath': 'path/to/file.pdf',
      'isSent': false,
      'patientId': '123',
      'createdAt': '2024-06-01',
    };

    test('fetchLabResults returns a list of LabResult objects on success', () async {
      // Arrange
      when(mockApiClient.get('/lab-results')).thenAnswer(
        (_) async => Response(
          data: [mockLabResultJson],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/lab-results'),
        ),
      );

      // Act
      final results = await labResultsService.fetchLabResults();

      // Assert
      expect(results, isA<List<LabResult>>());
      expect(results.length, 1);
      expect(results[0].id, 1);
      expect(results[0].title, 'Blood Test');       
      verify(mockApiClient.get('/lab-results')).called(1);
    });

    test('getDownloadUrl returns the correct URL', () {
      // Act
      final url = labResultsService.getDownloadUrl(5);

      // Assert
      expect(url, '${ApiClient.baseUrl}/lab-results/download/5');
    });

    test('fetchLabResults throws exception on error', () async {
      // Arrange
      when(mockApiClient.get('/lab-results')).thenThrow(Exception('API error'));

      // Assert
      expect(() => labResultsService.fetchLabResults(), throwsA(isA<Exception>()));
    });
  });
}
