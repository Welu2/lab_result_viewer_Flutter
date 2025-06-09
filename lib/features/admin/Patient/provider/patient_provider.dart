import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/api/api_client.dart';
import '../model/auth_response.dart';
import '../model/create_profile_request.dart';
import '../model/patient_profile.dart';
import '../service/patient_service.dart';

// Provide Dio-based ApiClient instance
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provide FlutterSecureStorage instance
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Provide PatientService with injected ApiClient and SecureStorage
final patientServiceProvider = Provider<PatientService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  // Note: PatientService currently creates its own storage internally.
  // For better testability, consider injecting FlutterSecureStorage via constructor.
  return PatientService(apiClient);
});

// ----- Parameters classes for FutureProvider.family -----


class UpdatePatientProfileParams {
  final int id;
  final PatientProfile updatedProfile;

  UpdatePatientProfileParams({
    required this.id,
    required this.updatedProfile,
  });
}

// ----- FutureProviders for async operations -----

// Register and create profile


final createUserAndProfileProvider =
    FutureProvider.family<void, CreateProfileRequest>((ref, request) async {
  final service = ref.read(patientServiceProvider);
  await service.createUserAndProfile(request);
});


// Fetch all patients (admin)
final fetchAllPatientsProvider =
    FutureProvider<List<PatientProfile>>((ref) async {
  final service = ref.read(patientServiceProvider);
  return service.fetchAllPatients();
});

// Update a patient profile by ID
final updatePatientProfileProvider =
    FutureProvider.family<void, UpdatePatientProfileParams>(
        (ref, params) async {
  final service = ref.read(patientServiceProvider);
  await service.updatePatientProfile(params.id, params.updatedProfile);
});
