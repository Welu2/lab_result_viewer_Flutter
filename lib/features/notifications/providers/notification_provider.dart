import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/session_manager.dart';

class NotificationProvider with ChangeNotifier {
  final ApiClient _apiClient;
  final SessionManager _sessionManager;
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  NotificationProvider({
    required ApiClient apiClient,
    required SessionManager sessionManager,
  })  : _apiClient = apiClient,
        _sessionManager = sessionManager;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get('/notifications/user');
      _notifications = (response.data as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _apiClient.patch('/notifications/$id/read');
      await loadNotifications(); // Refresh the list
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final unread = _notifications.where((n) => !n.isRead);
    for (final notification in unread) {
      await markAsRead(notification.id);
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiClient.get('/notifications/unread-count');
      _unreadCount = response.data['count'] ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }
} 