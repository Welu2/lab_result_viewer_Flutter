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
    await _apiClient.patch('/profile/update-email', data: {'email': newEmail});
  }

  Future<void> toggleNotifications(bool enabled) async {
    await _apiClient.put('/profile/notifications', data: {'enabled': enabled});
  }

  Future<bool> deleteProfile(String profileId) async {
    try {
      // First, delete all notifications for this user
      await _apiClient.delete('/notifications/user');
      
      // Then delete the profile
      final profileResponse = await _apiClient.delete('/profile/$profileId');
      if (profileResponse.statusCode != 200) {
        return false;
      }

      // Finally, delete the user
      final userResponse = await _apiClient.delete('/users/me');
      return userResponse.statusCode == 200;
    } catch (e) {
      print('Error deleting profile and user: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _sessionManager.clearSession();
  }
} 