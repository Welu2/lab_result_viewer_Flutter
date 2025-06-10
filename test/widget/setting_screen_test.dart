// test/widgets/admin_settings_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 1) your provider & test‐double imports
import 'package:lab_result_viewer/features/auth/providers/auth_provider.dart';
import '../_test_doubles.dart';

// 2) the screen under test
import 'package:lab_result_viewer/features/admin/Setting/screen/setting_screen.dart';

void main() {
  testWidgets(
    'AdminSettingsScreen renders all UI elements and back arrow works',
    (tester) async {
      var backPressed = false;

      // 3) Create a GoRouter with a single route for `/setting`
      final router = GoRouter(
        initialLocation: '/setting',
        routes: [
          GoRoute(
            path: '/setting',
            builder: (context, state) {
              return AdminSettingsScreen(
                onBack: () => backPressed = true,
              );
            },
          ),
        ],
      );

      // 4) Build widget with both ProviderScope and MaterialApp.router
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // override AuthService so logout() is a no-op
            authServiceProvider.overrideWithValue(FakeAuthService()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Let it settle
      await tester.pumpAndSettle();

      // 5) Back arrow
      final backFinder = find.byIcon(Icons.arrow_back);
      expect(backFinder, findsOneWidget);

      // Tap it and confirm onBack ran
      await tester.tap(backFinder);
      await tester.pump();
      expect(backPressed, isTrue);

      // 6) Verify titles and subtitles
      expect(find.text('Settings'), findsNWidgets(2));
      expect(
        find.text('Manage your account and app preferences'),
        findsOneWidget,
      );

      // 7) Verify Account header
      expect(find.text('Account'), findsOneWidget);

      // 8) Verify the three menu items
      expect(find.text('Profile Information'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);

      // 9) Verify the logout card (icon + text)
      expect(find.text('Log Out'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    },
  );
}
