import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/session_manager.dart';
import '../models/auth_models.dart';
//import '../models/create_profile_request.dart';

class AuthService {
  final ApiClient _apiClient;
  final SessionManager _sessionManager;

  AuthService(this._apiClient, this._sessionManager);

  Future<AuthResponse> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _apiClient.post('/auth/login', data: request.toJson());
    
    final authResponse = AuthResponse.fromJson(response.data);
    await _sessionManager.saveSession(
      token: authResponse.accessToken,
      role: authResponse.role,
      userId: authResponse.userId,
      email: authResponse.email,
    );
    
    return authResponse;
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post('/auth/signup', data: {
        'email': email,
        'password': password,
      });
      
      print('Registration response: ${response.data}');
      
      final token = response.data['token']['access_token'] as String;
      await _sessionManager.saveToken(token);
      
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> createProfile(CreateProfileRequest request) async {
    print('Creating profile with data: ${request.toJson()}'); // Debug log
    final response = await _apiClient.post('/profile', data: request.toJson());
    print('Profile creation response: ${response.data}'); // Debug log
    return response.data;
  }

  Future<void> logout() async {
    await _sessionManager.clearSession();
  }

  Future<bool> isAuthenticated() async {
    return await _sessionManager.isAuthenticated();
  }

  Future<String?> getUserRole() async {
    return await _sessionManager.getUserRole();
  }

  Future<String?> getToken() async {
    return await _sessionManager.getToken();
  }
} 