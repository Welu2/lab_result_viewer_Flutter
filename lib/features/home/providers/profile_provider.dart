import 'package:flutter/material.dart';
import '../../../core/auth/session_manager.dart';
import '../../../core/api/api_client.dart';

class ProfileProvider extends ChangeNotifier {
  final SessionManager _sessionManager;
  final ApiClient _apiClient;

  String? _name;
  bool _isLoading = false;
  String? _error;

  ProfileProvider(this._sessionManager, this._apiClient);

  String? get name => _name;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final userId = await _sessionManager.getUserId();
      if (userId == null) throw Exception('User not logged in');
      print('Fetching profile for user: $userId');
      final response = await _apiClient.get('/profile/me');
      print('Profile response: ${response.data}');
      _name = response.data['name'] ?? '';
      print('Set name to: $_name');
      notifyListeners();
    } catch (e) {
      print('Error fetching profile: $e');
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 