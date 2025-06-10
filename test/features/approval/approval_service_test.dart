import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';

import 'package:lab_result_viewer/core/api/api_client.dart';
import 'package:lab_result_viewer/features/admin/Approval/models/approval_model.dart';
import 'package:lab_result_viewer/features/admin/Approval/services/approval_service.dart';

import 'approval_service_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late MockApiClient mockApiClient;
  late AppointmentsService approvalService;

  setUp(() {
    mockApiClient = MockApiClient();
    approvalService = AppointmentsService(mockApiClient);
  });

  group('ApprovalService', () {
    test('fetchAllAppointments returns a list of Appointment', () async {
      when(mockApiClient.get('/appointments')).thenAnswer(
            (_) async => Response(
          data: [
            <String, dynamic>{'id': 1, 'status': 'confirmed'},
            <String, dynamic>{'id': 2, 'status': 'pending'},
          ],
          requestOptions: RequestOptions(path: '/appointments'),
        ),
      );

      final result = await approvalService.fetchAllAppointments();

      expect(result, isA<List<Appointment>>());
      expect(result.length, 2);
      expect(result[0].id, 1);
    });

    test('fetchPendingAppointments returns only pending appointments', () async {
      when(mockApiClient.get(
        '/appointments',
        queryParameters: {'status': 'pending'},
      )).thenAnswer(
            (_) async => Response(
          data: [
            <String, dynamic>{'id': 3, 'status': 'pending'}
          ],
          requestOptions: RequestOptions(path: '/appointments'),
        ),
      );

      final result = await approvalService.fetchPendingAppointments();

      expect(result.length, 1);
      expect(result[0].status, 'pending');
    });

    test('approve calls patch with correct parameters', () async {
      when(mockApiClient.patch(any, data: anyNamed('data'))).thenAnswer(
            (_) async => Response(
          data: null,
          requestOptions: RequestOptions(path: '/appointments/10/status'),
          statusCode: 200,
        ),
      );

      await approvalService.approve(10);

      verify(mockApiClient.patch(
        '/appointments/10/status',
        data: {'status': 'confirmed'},
      )).called(1);
    });

    test('decline calls patch with correct parameters', () async {
      when(mockApiClient.patch(any, data: anyNamed('data'))).thenAnswer(
            (_) async => Response(
          data: null,
          requestOptions: RequestOptions(path: '/appointments/5/status'),
          statusCode: 200,
        ),
      );

      await approvalService.decline(5);

      verify(mockApiClient.patch(
        '/appointments/5/status',
        data: {'status': 'disapproved'},
      )).called(1);
    });
  });
}
