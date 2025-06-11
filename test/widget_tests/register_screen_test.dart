// test/widget/register_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lab_result_viewer/features/auth/providers/auth_provider.dart';
import 'package:lab_result_viewer/features/auth/screens/register_screen.dart';
import 'package:lab_result_viewer/core/auth/session_manager.dart';
import 'package:lab_result_viewer/core/api/api_client.dart';
import 'package:lab_result_viewer/features/auth/services/auth_service.dart';
import 'package:lab_result_viewer/features/auth/models/auth_models.dart';

// A no-op SessionManager

// A no-op SessionManager
class FakeSessionManager extends SessionManager {
  @override Future<void> saveSession({required String token, required String role, required int userId, required String email}) async {}
  @override Future<String?> getToken() async => 'fake';
  @override Future<String?> getUserRole() async => 'user';
  @override Future<bool> isAuthenticated() async => true;
  @override Future<void> clearSession() async {}
}

// Fake AuthService that returns a fixed role
class FakeAuthService extends AuthService {
  final String roleToReturn;
  FakeAuthService(this.roleToReturn) : super(ApiClient(), FakeSessionManager());

  @override
  Future<AuthResponse> register({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return AuthResponse(
      user: User(id: 1, patientId: 'p1', email: email, role: roleToReturn),
      token: Token(accessToken: 'token'),
    );
  }
}

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/success', builder: (_, __) => const Scaffold(body: Text('Success!'))),
        GoRoute(path: '/admin-dashboard', builder: (_, __) => const Scaffold(body: Text('Admin'))),
      ],
    );
  });

  Future<void> pumpRegister(WidgetTester tester, AuthService authService) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(authService)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('validation errors show under each field', (tester) async {
    await pumpRegister(tester, FakeAuthService('user'));

    final submitBtn = find.byType(ElevatedButton);

    // 1) Tap empty form
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump();
    expect(find.text('Please enter your email'), findsOneWidget);

    // 2) Fill bad email
    await tester.enterText(find.byType(TextFormField).at(0), 'bademail');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump();
    expect(find.text('Please enter a valid email'), findsOneWidget);

    // 3) Fill password too short
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump();
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);

    // 4) Mismatch confirm
    await tester.enterText(find.byType(TextFormField).at(1), 'abcdef');
    await tester.enterText(find.byType(TextFormField).at(2), 'ghijkl');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('user registration navigates to /success', (tester) async {
    await pumpRegister(tester, FakeAuthService('user'));

    // Fill valid
    await tester.enterText(find.byType(TextFormField).at(0), 'u@x.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'mypassword');
    await tester.enterText(find.byType(TextFormField).at(2), 'mypassword');

    final submitBtn = find.byType(ElevatedButton);
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump(); // start loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 10));
    await tester.pumpAndSettle();
    expect(find.text('Success!'), findsOneWidget);
  });

  testWidgets('admin registration navigates to /admin-dashboard', (tester) async {
    await pumpRegister(tester, FakeAuthService('admin'));

    // Fill valid
    await tester.enterText(find.byType(TextFormField).at(0), 'a@x.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'pass123');
    await tester.enterText(find.byType(TextFormField).at(2), 'pass123');

    final submitBtn = find.byType(ElevatedButton);
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pumpAndSettle();
    expect(find.text('Admin'), findsOneWidget);
  });
}
