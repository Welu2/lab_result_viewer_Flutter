import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:lab_result_viewer/features/notifications/services/notification_service.dart';
import 'package:lab_result_viewer/features/notifications/models/notification.dart';

@GenerateMocks([Dio])
import 'notification_service_test.mocks.dart';

void main() {
  late MockDio mockDio;
  late NotificationService notificationService;

  setUp(() {
    mockDio = MockDio();
    notificationService = NotificationService(mockDio);
  });

  group('NotificationService', () {
    const testToken = 'test-token';
    final testNotifications = [
      {
        'id': 1,
        'message': 'Test notification 1',
        'isRead': false,
        'type': 'lab-result',
        'recipientType': 'user',
        'createdAt': '2024-03-20T10:00:00Z',
        'patientId': '123'
      },
      {
        'id': 2,
        'message': 'Test notification 2',
        'isRead': true,
        'type': 'appointment',
        'recipientType': 'user',
        'createdAt': '2024-03-20T11:00:00Z',
        'patientId': null
      }
    ];

    test('fetchNotifications returns list of notifications on success', () async {
      // Arrange
      when(mockDio.get(
        '/notifications/user',
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: testNotifications,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/notifications/user'),
      ));

      // Act
      final result = await notificationService.fetchNotifications(testToken);

      // Assert
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].message, 'Test notification 1');
      expect(result[0].isRead, false);
      expect(result[0].type, 'lab-result');
      expect(result[0].recipientType, 'user');
      expect(result[0].createdAt, '2024-03-20T10:00:00Z');
      expect(result[0].patientId, '123');

      expect(result[1].id, 2);
      expect(result[1].message, 'Test notification 2');
      expect(result[1].isRead, true);
      expect(result[1].type, 'appointment');
      expect(result[1].recipientType, 'user');
      expect(result[1].createdAt, '2024-03-20T11:00:00Z');
      expect(result[1].patientId, null);

      verify(mockDio.get(
        '/notifications/user',
        options: anyNamed('options'),
      )).called(1);
    });

    test('fetchNotifications throws exception on error', () async {
      // Arrange
      when(mockDio.get(
        '/notifications/user',
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/notifications/user'),
        error: 'Network error',
      ));

      // Act & Assert
      expect(
        () => notificationService.fetchNotifications(testToken),
        throwsException,
      );
    });

    test('markAsRead successfully marks notification as read', () async {
      // Arrange
      const notificationId = 1;
      when(mockDio.patch(
        '/notifications/$notificationId/read',
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        statusCode: 200,
        requestOptions: RequestOptions(path: '/notifications/$notificationId/read'),
      ));

      // Act
      await notificationService.markAsRead(testToken, notificationId);

      // Assert
      verify(mockDio.patch(
        '/notifications/$notificationId/read',
        options: anyNamed('options'),
      )).called(1);
    });

    test('markAsRead throws exception on error', () async {
      // Arrange
      const notificationId = 1;
      when(mockDio.patch(
        '/notifications/$notificationId/read',
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/notifications/$notificationId/read'),
        error: 'Network error',
      ));

      // Act & Assert
      expect(
        () => notificationService.markAsRead(testToken, notificationId),
        throwsException,
      );
    });
  });
} 