import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:lab_result_viewer/core/api/api_client.dart';
import 'package:lab_result_viewer/features/appointments_user/services/appointment_service.dart';
import 'package:lab_result_viewer/features/appointments_user/models/appointment.dart';
import 'package:lab_result_viewer/features/notifications/services/notification_service.dart';

import 'appointment_service_test.mocks.dart';

@GenerateMocks([ApiClient, NotificationService])
void main() {
  late AppointmentService appointmentService;
  late MockApiClient mockApiClient;
  late MockNotificationService mockNotificationService;

  setUp(() {
    mockApiClient = MockApiClient();
    mockNotificationService = MockNotificationService();
    appointmentService = AppointmentService(mockApiClient, mockNotificationService);
  });

 

  group('AppointmentService', () {
    final mockAppointmentJson = {
      'id': '1',
      'date': '2024-03-20',
      'time': '10:00:00',
      'testType': 'BLOOD_TEST',
      'status': 'pending',
      'patientId': '123',
    };

    test('fetchUserAppointments returns list of appointments on success', () async {
      // Arrange
      when(mockApiClient.get('/appointments/me')).thenAnswer((_) async => 
        Response(data: [mockAppointmentJson], statusCode: 200, requestOptions: RequestOptions(path: '/appointments/me')));

      // Act
      final result = await appointmentService.fetchUserAppointments();

      // Assert
      expect(result, isA<List<Appointment>>());
      expect(result.length, 1);
      expect(result[0].id, '1');
      expect(result[0].status, 'pending');
      verify(mockApiClient.get('/appointments/me')).called(1);
    });

    test('bookAppointment creates appointment and sends notification', () async {
      // Arrange
      when(mockApiClient.post('/appointments', data: anyNamed('data')))
          .thenAnswer((_) async => Response(data: mockAppointmentJson, statusCode: 201, requestOptions: RequestOptions(path: '/appointments')));
      
      when(mockApiClient.post('/notifications/admin', data: anyNamed('data')))
          .thenAnswer((_) async => Response(data: {}, statusCode: 200, requestOptions: RequestOptions(path: '/notifications/admin')));

      // Act
      final result = await appointmentService.bookAppointment(
        'BLOOD_TEST', 
        '2024-03-20', 
        '10:00:00'
      );

      // Assert
      expect(result, isA<Appointment>());
      expect(result.id, '1');
      verify(mockApiClient.post('/appointments', data: anyNamed('data'))).called(1);
      verify(mockApiClient.post('/notifications/admin', data: anyNamed('data'))).called(1);
    });

    test('updateAppointment updates and sends notification', () async {
      // Arrange
      when(mockApiClient.put('/appointments/1', data: anyNamed('data')))
          .thenAnswer((_) async => Response(data: mockAppointmentJson, statusCode: 200, requestOptions: RequestOptions(path: '/appointments/1')));
      
      when(mockApiClient.post('/notifications/admin', data: anyNamed('data')))
          .thenAnswer((_) async => Response(data: {}, statusCode: 200, requestOptions: RequestOptions(path: '/notifications/admin')));

      // Act
      final result = await appointmentService.updateAppointment(
        '1', 
        'BLOOD_TEST', 
        '2024-03-21', 
        '11:00:00'
      );

      // Assert
      expect(result, isA<Appointment>());
      expect(result.date, '2024-03-20'); // From mock data
      verify(mockApiClient.put('/appointments/1', data: anyNamed('data'))).called(1);
      verify(mockApiClient.post('/notifications/admin', data: anyNamed('data'))).called(1);
    });

    test('deleteAppointment returns true on success', () async {
      // Arrange
      when(mockApiClient.delete('/appointments/1'))
          .thenAnswer((_) async => Response(data: null, statusCode: 204, requestOptions: RequestOptions(path: '/appointments/1')));

      // Act
      final result = await appointmentService.deleteAppointment('1');

      // Assert
      expect(result, true);
      verify(mockApiClient.delete('/appointments/1')).called(1);
    });

    test('approveAppointment updates status and sends notification', () async {
      // Arrange
      final approvedAppointment = {
        ...mockAppointmentJson,
        'status': 'approved'
      };
      
      when(mockApiClient.put('/appointments/1/approve', data: anyNamed('data')))
          .thenAnswer((_) async => Response(data: approvedAppointment, statusCode: 200, requestOptions: RequestOptions(path: '/appointments/1/approve')));
      
      when(mockApiClient.post('/notifications/user', data: anyNamed('data')))
          .thenAnswer((_) async => Response(data: {}, statusCode: 200, requestOptions: RequestOptions(path: '/notifications/user')));

      // Act
      final result = await appointmentService.approveAppointment('1', '123');

      // Assert
      expect(result, isA<Appointment>());
      expect(result.status, 'approved');
      verify(mockApiClient.put('/appointments/1/approve', data: anyNamed('data'))).called(1);
      verify(mockApiClient.post('/notifications/user', data: anyNamed('data'))).called(1);
    });

    // Error cases
    group('Error handling', () {
      test('fetchUserAppointments throws on API error', () async {
        when(mockApiClient.get('/appointments/me'))
            .thenThrow(Exception('Network error'));
        
        expect(() => appointmentService.fetchUserAppointments(), throwsA(isA<Exception>()));
      });

      test('bookAppointment throws on API error', () async {
        when(mockApiClient.post('/appointments', data: anyNamed('data')))
            .thenThrow(Exception('Network error'));
        
        expect(
          () => appointmentService.bookAppointment('BLOOD_TEST', '2024-03-20', '10:00:00'),
          throwsA(isA<Exception>())
        );
      });
    });
  });
}