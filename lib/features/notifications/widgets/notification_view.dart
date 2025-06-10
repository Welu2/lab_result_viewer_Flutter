import 'package:flutter/material.dart';
import '../models/notification.dart';

/// A stateless view of the notifications list:
/// • loading indicator
/// • “No notifications” placeholder
/// • list of [NotificationItem]s
/// It also surfaces a “Mark all as read” button.
class NotificationView extends StatelessWidget {
  final bool isLoading;
  final List<AppNotification> notifications;
  final VoidCallback onBack;
  final VoidCallback onMarkAll;
  final void Function(AppNotification) onTapItem;

  const NotificationView({
    super.key,
    required this.isLoading,
    required this.notifications,
    required this.onBack,
    required this.onMarkAll,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          key: const Key('back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        actions: [
          TextButton(
            key: const Key('mark_all'),
            onPressed: onMarkAll,
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: Builder(builder: (_) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (notifications.isEmpty) {
          return const Center(child: Text('No notifications'));
        }
        return ListView.builder(
          key: const Key('list'),
          itemCount: notifications.length,
          itemBuilder: (_, i) {
            final n = notifications[i];
            return NotificationItem(
              key: Key('item_${n.id}'),
              notification: n,
              onTap: () => onTapItem(n),
            );
          },
        );
      }),
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

  IconData _iconFor(String type) {
    switch (type) {
      case 'lab-result': return Icons.notifications_outlined;
      case 'appointment': return Icons.event_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  String _titleFor(String type) {
    switch (type) {
      case 'lab-result': return 'Lab Results Ready';
      case 'appointment': return 'Appointment Reminder';
      default: return 'Notification';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = notification.isRead
        ? Colors.white
        : const Color(0xFFE3F2FD);
    final iconColor = notification.isRead
        ? Colors.grey
        : const Color(0xFF388E3C);

    return InkWell(
      key: Key('ink_${notification.id}'),
      onTap: onTap,
      child: Container(
        color: bg,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_iconFor(notification.type), color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_titleFor(notification.type),
                      key: Key('title_${notification.id}'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(notification.message,
                      key: Key('msg_${notification.id}')),
                  Text(notification.createdAt.substring(0, 10),
                      key: Key('date_${notification.id}'),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                key: Key('dot_${notification.id}'),
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
}
