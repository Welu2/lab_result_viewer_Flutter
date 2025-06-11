import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_result_viewer/features/notifications/widgets/notification_view.dart';
import 'package:lab_result_viewer/features/notifications/models/notification.dart';

void main() {
  final read = AppNotification(
    id: 1,
    message: 'Test 1',
    isRead: true,
    type: 'lab-result',
    recipientType: 'user',
    createdAt: '2025-06-01T12:00:00Z',
  );
  final unread = AppNotification(
    id: 2,
    message: 'Test 2',
    isRead: false,
    type: 'appointment',
    recipientType: 'user',
    createdAt: '2025-06-02T15:30:00Z',
  );

  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('loading state shows spinner', (tester) async {
    await tester.pumpWidget(wrap(
      NotificationView(
        isLoading: true,
        notifications: [],
        onBack: () {},
        onMarkAll: () {},
        onTapItem: (_) {},
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('empty state shows placeholder', (tester) async {
    await tester.pumpWidget(wrap(
      NotificationView(
        isLoading: false,
        notifications: [],
        onBack: () {},
        onMarkAll: () {},
        onTapItem: (_) {},
      ),
    ));
    expect(find.text('No notifications'), findsOneWidget);
  });

  testWidgets('renders list and callbacks', (tester) async {
    bool back = false, markAll = false;
    int? tappedId;

    await tester.pumpWidget(wrap(
      NotificationView(
        isLoading: false,
        notifications: [read, unread],
        onBack: () => back = true,
        onMarkAll: () => markAll = true,
        onTapItem: (n) => tappedId = n.id,
      ),
    ));
    await tester.pumpAndSettle();

    // Back button
    await tester.tap(find.byKey(const Key('back_button')));
    await tester.pump();
    expect(back, isTrue);

    // Mark all
    await tester.tap(find.byKey(const Key('mark_all')));
    await tester.pump();
    expect(markAll, isTrue);

    // List items
    expect(find.byKey(const Key('item_1')), findsOneWidget);
    expect(find.byKey(const Key('item_2')), findsOneWidget);

    // Verify read item has no dot
    expect(find.byKey(const Key('dot_1')), findsNothing);
    // Unread has dot
    expect(find.byKey(const Key('dot_2')), findsOneWidget);

    // Tap unread item
    await tester.tap(find.byKey(const Key('ink_2')));
    await tester.pump();
    expect(tappedId, 2);
  });
}
