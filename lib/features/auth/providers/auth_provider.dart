import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/auth_models.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError('AuthService must be provided');
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthState {
  final bool isLoading;
  final String? error;
  final String? userRole;

  AuthState({
    this.isLoading = false,
    this.error,
    this.userRole,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? userRole,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userRole: userRole ?? this.userRole,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.login(email, password);
      
      // Get role and token from session manager after successful login
      final role = await _authService.getUserRole();
      final token = await _authService.getToken();

      print('AuthNotifier Login Success - Role: $role');
      print('AuthNotifier Login Success - Token (first 10 chars): ${token?.substring(0, 10)}...');

      state = state.copyWith(
        isLoading: false,
        userRole: role,
      );
      return true;
    } catch (e) {
      print('AuthNotifier Login Error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<String?> register({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.register(
        email: email,
        password: password,
      );
      
      // Save the session with the token and user info
      await _authService.saveSession(
        token: response.token.accessToken,
        role: response.user.role,
        userId: response.user.id,
        email: response.user.email,
      );
      
      state = state.copyWith(
        isLoading: false,
        userRole: response.user.role,
      );
      return response.user.role;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<bool> createProfile(CreateProfileRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.createProfile(request);
      state = state.copyWith(
        isLoading: false,
        userRole: response.user.role,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = state.copyWith(
      userRole: null,
      error: null,
    );
  }

  Future<bool> checkAuthStatus() async {
    return await _authService.isAuthenticated();
  }

  Future<void> loadUserRole() async {
    final role = await _authService.getUserRole();
    state = state.copyWith(userRole: role);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}