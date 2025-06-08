import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab_result_viewer/core/api/api_client.dart';
import 'package:lab_result_viewer/core/auth/session_manager.dart';
import '../services/profile_service.dart';

// Define the profile state
class ProfileState {
  final bool isLoading;
  final String? error;
  final String? id;
  final String? name;
  final String? email;
  final String? dateOfBirth;
  final String? gender;
  final double? height;
  final double? weight;
  final String? bloodType;
  final String? relative;
  final bool notificationsEnabled;
  final String? role;

  ProfileState({
    this.isLoading = false,
    this.error,
    this.id,
    this.name,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    this.bloodType,
    this.relative,
    this.notificationsEnabled = false,
    this.role,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    String? id,
    String? name,
    String? email,
    String? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    String? bloodType,
    String? relative,
    bool? notificationsEnabled,
    String? role,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bloodType: bloodType ?? this.bloodType,
      relative: relative ?? this.relative,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      role: role ?? this.role,
    );
  }

  bool get isAdmin => role == 'admin';
}

// Define the profile notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _profileService;
  final SessionManager _sessionManager;

  ProfileNotifier(this._profileService, this._sessionManager) : super(ProfileState()) {
    _initializeRole();
  }

  Future<void> _initializeRole() async {
    final role = await _profileService.getUserRole();
    state = state.copyWith(role: role);
  }

  Future<void> fetchProfile() async {
    // Only fetch profile if user is not admin
    final isAdmin = await _profileService.isAdmin();
    if (isAdmin) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _profileService.getProfile();
      state = state.copyWith(
        isLoading: false,
        id: data['id']?.toString(),
        name: data['name'],
        email: data['email'],
        dateOfBirth: data['dateOfBirth'],
        gender: data['gender'],
        height: data['height']?.toDouble(),
        weight: data['weight']?.toDouble(),
        bloodType: data['bloodType'],
        relative: data['relative'],
        notificationsEnabled: data['notificationsEnabled'] ?? false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleNotificationSetting(bool value) async {
    try {
      await _profileService.toggleNotifications(value);
      state = state.copyWith(notificationsEnabled: value);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> changeEmail(String newEmail) async {
    try {
      await _profileService.changeEmail(newEmail);
      state = state.copyWith(email: newEmail);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _profileService.logout();
      state = ProfileState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> deleteProfile(String profileId) async {
    try {
      final success = await _profileService.deleteProfile(profileId);
      if (success) {
        await _sessionManager.clearSession();
      }
      return success;
    } catch (e) {
      print('Error in deleteProfile: $e');
      return false;
    }
  }
}

// Define the providers
final profileServiceProvider = Provider<ProfileService>((ref) {
  throw UnimplementedError('ProfileService must be provided');
});

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  final sessionManager = ref.watch(sessionManagerProvider);
  return ProfileNotifier(profileService, sessionManager);
});

// Providers for dependencies
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final sessionManagerProvider = Provider<SessionManager>((ref) => SessionManager()); 