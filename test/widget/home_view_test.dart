import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_result_viewer/features/home/widgets/home_view.dart';

void main() {
  testWidgets('HomeView renders correctly and handles taps',
      (WidgetTester tester) async {
    var notifTapped = false;
    var searchValue = '';
    var tappedService = '';

    await tester.pumpWidget(
      MaterialApp(
        home: HomeView(
          userName: 'Bob',
          unreadNotifications: 2,
          totalTests: 7,
          abnormalResults: 1,
          services: ['A', 'B'],
          onNotificationsTap: () {
            notifTapped = true;
          },
          onRefresh: () async {},
          onSearchChanged: (val) {
            searchValue = val;
          },
          onServiceTap: (service) {
            tappedService = service;
          },
        ),
      ),
    );

    // 1) Avatar initial: find Text inside CircleAvatar
    expect(find.widgetWithText(CircleAvatar, 'B'), findsOneWidget);

    // 2) Greeting text
    expect(find.text('Hello, Bob'), findsOneWidget);

    // 3) Notification icon + tap handler
    final notifIcon = find.byIcon(Icons.notifications_outlined);
    expect(notifIcon, findsOneWidget);
    await tester.tap(notifIcon);
    expect(notifTapped, isTrue);

    // 4) Service cards: A and B
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Book now!'), findsNWidgets(2));
    // Tap on the 'A' card
    await tester.tap(find.text('A'));
    expect(tappedService, 'A');

    // 5) Health summary values
    expect(find.text('7'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    // 6) Search field interaction
    final tf = find.byType(TextField);
    await tester.enterText(tf, 'foo');
    expect(searchValue, 'foo');
  });
}
