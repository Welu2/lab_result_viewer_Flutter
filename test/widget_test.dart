import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab_result_viewer/core/auth/session_manager.dart';
import 'package:lab_result_viewer/core/api/api_client.dart';
import 'package:lab_result_viewer/features/home/screens/user_profile_screen.dart';
import 'package:lab_result_viewer/features/home/providers/profile_provider.dart';
import 'package:lab_result_viewer/features/home/services/profile_service.dart';

void main() {
  group('UserProfileScreen Tests', () {
    late ProfileService mockService;
    late SessionManager mockSessionManager;

    setUp(() {
      mockSessionManager = FakeSessionManager();
      mockService = ProfileService(FakeSessionManager(), FakeApiClient());
    });

    testWidgets('displays loading indicator when loading', (tester) async {
      final notifier = ProfileNotifier(mockService, mockSessionManager);
      notifier.state = ProfileState(isLoading: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileServiceProvider.overrideWithValue(mockService),
            sessionManagerProvider.overrideWithValue(mockSessionManager),
            profileProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(home: UserProfileScreen()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays user name when loaded', (tester) async {
      final notifier = ProfileNotifier(mockService, mockSessionManager);
      notifier.state = ProfileState(name: 'John Doe');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileServiceProvider.overrideWithValue(mockService),
            sessionManagerProvider.overrideWithValue(mockSessionManager),
            profileProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(home: UserProfileScreen()),
        ),
      );

      expect(find.text('John Doe'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays error message and retry button', (tester) async {
      final notifier = ProfileNotifier(mockService, mockSessionManager);
      notifier.state = ProfileState(error: 'Failed to load');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileServiceProvider.overrideWithValue(mockService),
            sessionManagerProvider.overrideWithValue(mockSessionManager),
            profileProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(home: UserProfileScreen()),
        ),
      );

      expect(find.text('Error: Failed to load'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}

// ✅ Correct return type: int?
class FakeSessionManager extends SessionManager {
  @override
  Future<int?> getUserId() async => 123;
}

// Your FakeApiClient remains unchanged:
class FakeApiClient extends ApiClient {
  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'name': 'John Doe'},
      statusCode: 200,
    );
  }

  @override
  Future<Response> post(String path, {dynamic data}) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'success': true},
      statusCode: 201,
    );
  }
}
