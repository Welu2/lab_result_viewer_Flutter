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

  Future<AuthResponse> register(String email, String password) async {
    try {
      final request = RegisterRequest(email: email, password: password);
      final response = await _apiClient.post('/auth/signup', data: request.toJson());
      
      final authResponse = AuthResponse.fromJson(response.data);
      await _sessionManager.saveSession(
        token: authResponse.accessToken,
        role: authResponse.role,
        userId: authResponse.userId,
        email: authResponse.email,
      );
      
      return authResponse;
    } catch (e) {
      if (e.toString().contains('User already exists')) {
        throw Exception('An account with this email already exists. Please try logging in instead.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createProfile(CreateProfileRequest request) async {
    final response = await _apiClient.post('/profile', data: request.toJson());
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