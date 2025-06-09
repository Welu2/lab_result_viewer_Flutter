import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
// We still need the real JwtDecoder because the AuthService uses it.
// We just won't be mocking it in the test.
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lab_result_viewer/core/api/api_client.dart';
import 'package:lab_result_viewer/core/auth/session_manager.dart';
import 'package:lab_result_viewer/features/auth/services/auth_service.dart';
import 'package:lab_result_viewer/features/auth/models/auth_models.dart';

import 'auth_service_test.mocks.dart';

// REMOVED: The MockJwtDecoder class is no longer necessary.

@GenerateMocks([ApiClient, SessionManager])
void main() {
  late AuthService authService;
  late MockApiClient mockApiClient;
  late MockSessionManager mockSessionManager;

  setUp(() {
    mockApiClient = MockApiClient();
    mockSessionManager = MockSessionManager();
    authService = AuthService(mockApiClient, mockSessionManager);
  });

  group('AuthService', () {
    // This token, when decoded by the real JwtDecoder, will contain:
    // 'email': 'abi@gmail.com', 'sub': 21, 'role': 'user'
    final Map<String, dynamic> mockLoginResponse = {
      "message": "Login successful",
      "token": {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImFiaUBnbWFpbC5jb20iLCJzdWIiOjIxLCJyb2xlIjoidXNlciIsImlhdCI6MTc0OTM3OTY2NywiZXhwIjoxNzQ5MzgzMjY3fQ.44oEWhgBMpireUqLZif669m4-hnaRmqdHAoDUmPfJNM"
      }
    };

    // This token, when decoded, will contain:
    // 'email': 'babishaa@gmail.com', 'sub': 30, 'role': 'user'
    final Map<String, dynamic> mockSignupResponse = {
      "user": {
        "id": 30,
        "patientId": "PAT-00017",
        "email": "babishaa@gmail.com",
        "password": "\$2b\$10\$9zhbshldDSedFLb89vF/d.YhJyuqRWm34vpl/mBCZzEngIvbkuYre",
        "role": "user"
      },
      "token": {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImJhYmlzaGFhQGdtYWlsLmNvbSIsInN1YiI6MzAsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNzQ5NDY1MzQ2LCJleHAiOjE3NDk0Njg5NDZ9.-vBzDwZfHuaFhU1woJa8L7fwC5_5AWIIJsTyWsep-jU"
      }
    };

    test('login should return LoginResponse with access_token', () async {
      // Arrange
      when(mockApiClient.post('/auth/login', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                data: mockLoginResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/auth/login'),
              ));
      
      // We don't need a mock for saveToken if saveSession is what's important,
      // but it's fine to leave it.
      when(mockSessionManager.saveToken(any)).thenAnswer((_) async {});

      // Set up the expected call to saveSession
      when(mockSessionManager.saveSession(
        token: anyNamed('token'),
        role: anyNamed('role'),
        userId: anyNamed('userId'),
        email: anyNamed('email'),
      )).thenAnswer((_) async {});

      // REMOVED: The lines for mocking JwtDecoder.decode are gone.

      // Act
      final result = await authService.login('abi@gmail.com', 'password');
      
      // Assert
      expect(result, isA<LoginResponse>());
      expect(result.token.accessToken, mockLoginResponse['token']['access_token']);
      verify(mockApiClient.post('/auth/login', data: anyNamed('data'))).called(1);
      
      // VERIFY with the actual decoded values from the mock token
      verify(mockSessionManager.saveSession(
        token: mockLoginResponse['token']['access_token']!,
        role: 'user',
        userId: 21,
        email: 'abi@gmail.com',
      )).called(1);
    });

    test('register should return AuthResponse with user and token', () async {
      // Arrange
      when(mockApiClient.post('/auth/signup', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                data: mockSignupResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/auth/signup'),
              ));
      
      when(mockSessionManager.saveSession(
        token: anyNamed('token'),
        role: anyNamed('role'),
        userId: anyNamed('userId'),
        email: anyNamed('email'),
      )).thenAnswer((_) async {});

      // REMOVED: The lines for mocking JwtDecoder.decode are gone.

      // Act
      final result = await authService.register(
        email: 'babishaa@gmail.com',
        password: 'password',
      );

      // Assert
      expect(result, isA<AuthResponse>());
      expect(result.token.accessToken, mockSignupResponse['token']['access_token']);
      expect(result.user.email, 'babishaa@gmail.com');
      expect(result.user.role, 'user');
      expect(result.user.id, 30);
      verify(mockApiClient.post('/auth/signup', data: anyNamed('data'))).called(1);

      // VERIFY with the actual decoded values from the mock token
      verify(mockSessionManager.saveSession(
        token: mockSignupResponse['token']['access_token']!,
        role: 'user',
        userId: 30,
        email: 'babishaa@gmail.com',
      )).called(1);
    });

    test('login should throw error when credentials are invalid', () async {
      // Arrange
      // This is a DioError simulation, which is more realistic for HTTP errors.
      when(mockApiClient.post('/auth/login', data: anyNamed('data')))
          .thenThrow(DioException(
                response: Response(
                  data: {"message": "Invalid credentials"},
                  statusCode: 401,
                  requestOptions: RequestOptions(path: '/auth/login'),
                ),
                requestOptions: RequestOptions(path: '/auth/login'),
              ));

      // Act & Assert
      // The service should catch the DioException and rethrow a generic Exception.
      expect(
        () => authService.login('wrong@email.com', 'wrongpassword'),
        throwsA(isA<Exception>()),
      );
    });

    test('register should throw error when email is already taken', () async {
      // Arrange
      when(mockApiClient.post('/auth/signup', data: anyNamed('data')))
          .thenThrow(DioException(
              response: Response(
                data: {"message": "Email already in use"},
                statusCode: 400,
                requestOptions: RequestOptions(path: '/auth/signup'),
              ),
              requestOptions: RequestOptions(path: '/auth/signup'),
          ));

      // Act & Assert
      expect(
        () => authService.register(email: 'taken@email.com', password: 'password'),
        throwsA(isA<Exception>()),
      );
    });

    test('logout should clear session', () async {
      // Arrange
      when(mockSessionManager.clearSession()).thenAnswer((_) async {});

      // Act
      await authService.logout();

      // Assert
      verify(mockSessionManager.clearSession()).called(1);
    });
  });
}