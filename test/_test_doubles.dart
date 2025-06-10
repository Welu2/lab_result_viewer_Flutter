import 'package:lab_result_viewer/features/auth/services/auth_service.dart';
import 'package:lab_result_viewer/core/auth/session_manager.dart';
import 'package:lab_result_viewer/core/api/api_client.dart';

/// A SessionManager that does nothing, for logout/getToken/etc.
class FakeSessionManager extends SessionManager {
  @override
  Future<void> clearSession() async {
    // no-op
  }

  @override
  Future<String?> getToken() async => 'fake-token';

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<String?> getUserRole() async => 'user';

  // other methods can remain inherited
}

/// A fake AuthService that uses our FakeSessionManager and never hits real APIs.
class FakeAuthService extends AuthService {
  FakeAuthService()
      : super(
          ApiClient(),           // not used for logout
          FakeSessionManager(),  // no-op session manager
        );

  @override
  Future<void> logout() async {
    // no-op
  }

  // All other inherited methods are never called by the settings screen.
}

