import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/session_manager.dart';
import '../../../core/api/api_client.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  throw UnimplementedError('ProfileService must be provided');
});

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return ProfileNotifier(profileService);
});

class ProfileState {
  final String? name;
  final bool isLoading;
  final String? error;

  ProfileState({
    this.name,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    String? name,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      name: name ?? this.name,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProfileService {
  final SessionManager _sessionManager;
  final ApiClient _apiClient;

  ProfileService(this._sessionManager, this._apiClient);

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