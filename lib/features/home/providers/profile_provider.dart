import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab_result_viewer/core/api/api_client.dart';
import 'package:lab_result_viewer/core/auth/session_manager.dart';

// Define the profile state
class ProfileState {
  final bool isLoading;
  final String? error;
  final String? name;
  final String? dateOfBirth;
  final String? gender;
  final double? height;
  final double? weight;
  final String? bloodType;
  final String? relative;

  ProfileState({
    this.isLoading = false,
    this.error,
    this.name,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    this.bloodType,
    this.relative,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    String? name,
    String? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    String? bloodType,
    String? relative,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bloodType: bloodType ?? this.bloodType,
      relative: relative ?? this.relative,
    );
  }
}

// Define the profile notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ApiClient _apiClient;
  final SessionManager _sessionManager;

  ProfileNotifier(this._apiClient, this._sessionManager) : super(ProfileState());

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get('/profile/me');
      final data = response.data;
      state = state.copyWith(
        isLoading: false,
        name: data['name'],
        dateOfBirth: data['dateOfBirth'],
        gender: data['gender'],
        height: data['height']?.toDouble(),
        weight: data['weight']?.toDouble(),
        bloodType: data['bloodType'],
        relative: data['relative'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Define the provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final sessionManager = ref.watch(sessionManagerProvider);
  return ProfileNotifier(apiClient, sessionManager);
});

// Providers for dependencies
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final sessionManagerProvider = Provider<SessionManager>((ref) => SessionManager()); 