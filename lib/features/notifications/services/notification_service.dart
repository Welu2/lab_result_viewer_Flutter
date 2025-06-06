import 'package:dio/dio.dart';
import '../models/notification.dart';

class NotificationService {
  final Dio _dio;

  NotificationService(this._dio);

  Future<List<AppNotification>> getUserNotifications(String token) async {
    try {
      final response = await _dio.get(
        '/notifications/user',
        options: Options(
          headers: {'Authorization': token},
        ),
      );
      
      return (response.data as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<void> markAsRead(String token, int id) async {
    try {
      await _dio.patch(
        '/notifications/$id/read',
        options: Options(
          headers: {'Authorization': token},
        ),
      );
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
} 