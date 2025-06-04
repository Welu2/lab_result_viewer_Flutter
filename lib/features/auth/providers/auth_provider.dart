import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/auth_models.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  bool _isLoading = false;
  String? _userRole;
  String? _error;

  AuthProvider(this._authService);

  bool get isLoading => _isLoading;
  String? get userRole => _userRole;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      _userRole = response.role;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(email, password);
      _userRole = response.role;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProfile(CreateProfileRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.createProfile(request);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _userRole = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    return await _authService.isAuthenticated();
  }

  Future<void> loadUserRole() async {
    _userRole = await _authService.getUserRole();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}