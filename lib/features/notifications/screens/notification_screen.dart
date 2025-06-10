import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_view.dart';
import '../../../core/auth/session_manager.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  Future<String?> _getToken() async =>
      await SessionManager().getToken();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return NotificationView(
      isLoading: state.isLoading,
      notifications: state.notifications,
      onBack: () => context.pop(),
      onMarkAll: () async {
        final t = await _getToken();
        if (t != null) await notifier.markAllAsRead(t);
      },
      onTapItem: (n) async {
        final t = await _getToken();
        if (t != null) await notifier.markAsRead(t, n.id);
      },
    );
  }
}
