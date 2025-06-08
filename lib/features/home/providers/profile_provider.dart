import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/session_manager.dart';
import '../../../core/api/api_client.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  final sessionManager = SessionManager();
  final apiClient = ApiClient();
  return ProfileService(sessionManager, apiClient);
  throw UnimplementedError('ProfileService must be provided');
});

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return ProfileNotifier(profileService);
});

class ProfileState {
  final String? name;
  final String? dateOfBirth;
  final bool isLoading;
  final String? error;
  final String? email;
  final bool notificationsEnabled;

  ProfileState({
    this.name,
    this.dateOfBirth,
    this.isLoading = false,
    this.email,
    this.notificationsEnabled = true,
    this.error,
  });

  ProfileState copyWith({
    String? name,
    String? dateOfBirth,
    String? email,
    bool? notificationsEnabled,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProfileService {
  final SessionManager _sessionManager;
  final ApiClient _apiClient;

  ProfileService(this._sessionManager, this._apiClient);
  Future<void> logout() async {
    await _sessionManager.clearSession();
  }

  Future<void> changeEmail(String newEmail) async {
    await _apiClient.post('/profile/change-email', data: {
      'email': newEmail,
    });
  }

  Future<void> updateNotificationSetting(bool enabled) async {
    await _apiClient.post('/profile/notification-settings', data: {
      'enabled': enabled,
    });
  }

  Future<void> deleteProfile() async {
    final userId = await _sessionManager.getUserId();
    if (userId == null) throw Exception('User not logged in');
    await _apiClient.delete('/profile/$userId');
    await _sessionManager.clearSession();
  }

  Future<String?> fetchProfile() async {
    final userId = await _sessionManager.getUserId();
    if (userId == null) throw Exception('User not logged in');

    final response = await _apiClient.get('/profile/me');
    return response.data['name'] ?? '';
  }

  Future<void> createProfile({
    required String name,
  required String dateOfBirth,
  required String gender,
  double? height,
  double? weight,
  String? bloodType,
  String? relative,
  }) async {
    final userId = await _sessionManager.getUserId();
    if (userId == null) throw Exception('User not logged in');

    await _apiClient.post('/profile', data: {
      'name': name,
    'dateOfBirth': dateOfBirth,
    'gender': gender,
    if (height != null) 'height': height,
    if (weight != null) 'weight': weight,
    if (bloodType != null) 'bloodType': bloodType,
    if (relative != null) 'relative': relative,
    });
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _service;

  ProfileNotifier(this._service) : super(ProfileState());

  Future<void> logout() async {
    await _service.logout();
    state = ProfileState(); // reset state after logout
  }

  Future<void> changeEmail(String newEmail) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.changeEmail(newEmail);
      state = state.copyWith(isLoading: false, email: newEmail);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleNotificationSetting(bool enabled) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.updateNotificationSetting(enabled);
      state = state.copyWith(isLoading: false, notificationsEnabled: enabled);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.deleteProfile();
      state = ProfileState(); // reset state after deletion
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final name = await _service.fetchProfile();
      state = state.copyWith(
        isLoading: false,
        name: name,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createProfile({
  required String name,
  required String dateOfBirth,
  required String gender,
  double? height,
  double? weight,
  String? bloodType,
  String? relative,
}) async {
  state = state.copyWith(isLoading: true, error: null);
  try {
    await _service.createProfile(
      name: name,
      dateOfBirth: dateOfBirth,
      gender: gender,
      height: height,
      weight: weight,
      bloodType: bloodType,
      relative: relative,
    );
    state = state.copyWith(isLoading: false, name: name);
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}
}