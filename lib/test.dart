import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/providers/profile_provider.dart';
import '../features/home/screens/user_profile_screen.dart';
import '../core/api/api_client.dart';
import '../core/auth/session_manager.dart';

void main() {
  final mockNotifier = MockProfileNotifier(
    sessionManager: MockSessionManager(),
    apiClient: MockApiClient(),
    state: ProfileState(name: 'John Doe'),
  );

  runApp(
    ProviderScope(
      overrides: [
        profileServiceProvider.overrideWithValue(
          ProfileService(MockSessionManager(), MockApiClient()),
        ),
        profileProvider.overrideWith((ref) => mockNotifier),
      ],
      child: const MaterialApp(
        home: UserProfileScreen(),
      ),
    ),
  );
}

// Custom mock notifier using real ProfileNotifier structure
class MockProfileNotifier extends ProfileNotifier {
  MockProfileNotifier({
    ProfileState? state,
    required SessionManager sessionManager,
    required ApiClient apiClient,
  }) : super(ProfileService(sessionManager, apiClient)) {
    if (state != null) this.state = state;
  }
}

// Simple mock API client
class MockApiClient extends ApiClient {
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

// Simple mock session manager
class MockSessionManager extends SessionManager {
  @override
  Future<String?> getUserId() async => 'mock-user-id';
}
