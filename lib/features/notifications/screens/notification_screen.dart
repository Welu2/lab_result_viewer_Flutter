import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/session_manager.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  Future<String?> _getToken() async {
    final sessionManager = SessionManager();
    return await sessionManager.getToken();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final token = await _getToken();
              if (token != null) {
                await ref.read(notificationProvider.notifier).markAllAsRead(token);
              }
            },
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.notifications.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }

          return ListView.builder(
            itemCount: state.notifications.length,
            itemBuilder: (context, index) {
              final notification = state.notifications[index];
              return NotificationItem(
                notification: notification,
                onTap: () async {
                  final token = await _getToken();
                  if (token != null) {
                    await ref.read(notificationProvider.notifier).markAsRead(token, notification.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = notification.isRead
        ? Colors.white
        : const Color(0xFFE3F2FD);
    final iconColor = notification.isRead
        ? Colors.grey
        : const Color(0xFF388E3C);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _getIconForType(notification.type),
              color: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitleForType(notification.type),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(notification.message),
                  Text(
                    notification.createdAt.substring(0, 10),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF388E3C),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'lab-result':
        return Icons.notifications_outlined;
      case 'appointment':
        return Icons.event_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _getTitleForType(String type) {
    switch (type) {
      case 'lab-result':
        return 'Lab Results Ready';
      case 'appointment':
        return 'Appointment Reminder';
      default:
        return 'Notification';
    }
  }
} 