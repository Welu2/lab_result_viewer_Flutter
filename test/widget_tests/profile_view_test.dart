// test/widgets/profile_view_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_result_viewer/features/home/widgets/profile_view.dart';

void main() {
  testWidgets('Loading state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ProfileView(
        isLoading: true,
        error: null,
        name: '',
        dateOfBirth: '',
        onRetry: () {},
        onChangeEmail: () {},
        onNotificationSetting: () {},
        onLogout: () {},
        onDelete: () {},
      )),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Error state with retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(home: ProfileView(
        isLoading: false,
        error: 'Network failure',
        name: '',
        dateOfBirth: '',
        onRetry: () => retried = true,
        onChangeEmail: () {},
        onNotificationSetting: () {},
        onLogout: () {},
        onDelete: () {},
      )),
    );
    expect(find.text('Error: Network failure'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('Data state shows profile and actions', (tester) async {
    var changeEmail = false, notif = false, logout = false, delete = false;
    await tester.pumpWidget(
      MaterialApp(home: ProfileView(
        isLoading: false,
        error: null,
        name: 'Charlie',
        dateOfBirth: '1990-01-01',
        onRetry: () {},
        onChangeEmail: () => changeEmail = true,
        onNotificationSetting: () => notif = true,
        onLogout: () => logout = true,
        onDelete: () => delete = true,
      )),
    );
    // Header
    expect(find.text('Charlie'), findsOneWidget);
    expect(find.text('1990-01-01'), findsOneWidget);
    // Actions
    await tester.tap(find.text('Change Email'));
    expect(changeEmail, isTrue);
    await tester.tap(find.text('Notification Setting'));
    expect(notif, isTrue);
    await tester.tap(find.text('Log out'));
    expect(logout, isTrue);
    await tester.tap(find.text('Delete Profile'));
    expect(delete, isTrue);
  });
}
