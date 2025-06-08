import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/session_manager.dart';
import '../models/auth_models.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
//import '../models/create_profile_request.dart';

class AuthService {
  final ApiClient _apiClient;
  final SessionManager _sessionManager;

  AuthService(this._apiClient, this._sessionManager);

  Future<LoginResponse> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _apiClient.post('/auth/login', data: request.toJson());
    
    final loginResponse = LoginResponse.fromJson(response.data);
    await _sessionManager.saveToken(loginResponse.token.accessToken);
    
    // Decode JWT token to get role
    final decodedToken = JwtDecoder.decode(loginResponse.token.accessToken);
    final role = decodedToken['role'] as String;
    final userId = decodedToken['sub'] as int;
    
    // Save complete session
    await _sessionManager.saveSession(
      token: loginResponse.token.accessToken,
      role: role,
      userId: userId,
      email: email,
    );
    
    return loginResponse;
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    try {
      final request = RegisterRequest(email: email, password: password);
      final response = await _apiClient.post('/auth/signup', data: request.toJson());
      print('Registration response: ${response.data}');
      
      final authResponse = AuthResponse.fromJson(response.data);
      
      // Save the session after successful registration
      await saveSession(
        token: authResponse.token.accessToken,
        role: authResponse.user.role,
        userId: authResponse.user.id,
        email: authResponse.user.email,
      );
      
      return authResponse;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<void> saveSession({
    required String token,
    required String role,
    required int userId,
    required String email,
  }) async {
    await _sessionManager.saveSession(
      token: token,
      role: role,
      userId: userId,
      email: email,
    );
  }

  Future<ProfileResponse> createProfile(CreateProfileRequest request) async {
    print('Creating profile with data: ${request.toJson()}');
    try {
      final token = await _sessionManager.getToken();
      print('Current auth token: $token');
      
      if (token == null) {
        throw Exception('No authentication token found. Please log in again.');
      }
      
      // Validate required fields
      if (request.name.isEmpty) {
        throw Exception('Name is required');
      }
      if (request.dateOfBirth.isEmpty) {
        throw Exception('Date of birth is required');
      }
      if (request.gender.isEmpty) {
        throw Exception('Gender is required');
      }
      
      final response = await _apiClient.post('/profile', data: request.toJson());
      print('Profile creation response: ${response.data}');
      
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create profile. Status code: ${response.statusCode}');
      }
      
      return ProfileResponse.fromJson(response.data);
    } catch (e) {
      print('Error creating profile: $e');
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Session expired. Please log in again.');
        }
        if (e.response?.statusCode == 400) {
          throw Exception('Invalid profile data. Please check your input.');
        }
      }
      rethrow;
    }
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

  Future<ProfileResponse> getProfile() async {
    try {
      final response = await _apiClient.get('/profile/me');
      return ProfileResponse.fromJson(response.data);
    } catch (e) {
      print('Error getting profile: $e');
      rethrow;
    }
  }
} 