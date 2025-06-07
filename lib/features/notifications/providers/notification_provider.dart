import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/session_manager.dart';
import '../services/notification_service.dart';
import 'package:dio/dio.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  // You can use Dio or ApiClient as needed
  return NotificationService(ApiClient().dio);
});

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationNotifier(notificationService);
});

class NotificationState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final int unreadCount;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    int? unreadCount,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _service;

  NotificationNotifier(this._service) : super(NotificationState());

  Future<void> fetchNotifications(String token) async {
    state = state.copyWith(isLoading: true);
    try {
      final notifications = await _service.fetchNotifications(token);
      state = state.copyWith(
        isLoading: false,
        notifications: notifications,
        unreadCount: notifications.where((n) => !n.isRead).length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> markAsRead(String token, int id) async {
    try {
      await _service.markAsRead(token, id);
      await fetchNotifications(token); // Refresh the list
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> markAllAsRead(String token) async {
    final unread = state.notifications.where((n) => !n.isRead);
    for (final notification in unread) {
      await markAsRead(token, notification.id);
    }
  }
} 