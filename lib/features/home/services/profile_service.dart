import 'package:lab_result_viewer/core/api/api_client.dart';
import 'package:lab_result_viewer/core/auth/session_manager.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfileService {
  final SessionManager _sessionManager;
  final ApiClient _apiClient;

  ProfileService(this._sessionManager, this._apiClient);

  Future<String?> getUserRole() async {
    final token = await _sessionManager.getToken();
    if (token == null) return null;
    
    try {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.get('/profile/me');
    return response.data;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _apiClient.put('/profile/me', data: data);
  }

  Future<void> changeEmail(String newEmail) async {
    await _apiClient.put('/profile/email', data: {'email': newEmail});
  }

  Future<void> toggleNotifications(bool enabled) async {
    await _apiClient.put('/profile/notifications', data: {'enabled': enabled});
  }

  Future<void> deleteProfile() async {
    await _apiClient.delete('/profile/me');
    await _sessionManager.clearSession();
  }

  Future<void> logout() async {
    await _sessionManager.clearSession();
  }
} 