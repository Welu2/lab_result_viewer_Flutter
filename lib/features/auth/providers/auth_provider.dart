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
  final String? userRole;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.userRole,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? userRole,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      userRole: userRole ?? this.userRole,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.login(email, password);
      state = state.copyWith(
        isLoading: false,
        userRole: response.role,
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
      state = state.copyWith(
        isLoading: false,
        userRole: response.role,
      );
      return response.role;
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
      await _authService.createProfile(request);
      state = state.copyWith(isLoading: false);
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