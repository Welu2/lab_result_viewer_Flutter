import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../model/auth_response.dart';
import '../model/create_profile_request.dart';
import '../model/patient_profile.dart';
import '../../../../core/api/api_client.dart';

class PatientService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  PatientService(this._apiClient);

  // Register and create profile in one step
 Future<void> createUserAndProfile(CreateProfileRequest request) async {
    try {
      // Single-step: register user and profile using /auth/register
      final response = await _apiClient.post(
        '/auth/register',
        data: request.toRegisterJson(), // Combined user + profile data
      );

      final responseData = response.data;
      print('Register response: $responseData');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('User and profile registered successfully.');
      } else {
        throw 'Registration failed with status ${response.statusCode}';
      }
    } on DioError catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        final message = errorData['message'];
        if (message is String) {
          throw 'Request failed: $message';
        } else if (message is List && message.isNotEmpty) {
          throw 'Request failed: ${message.first}';
        }
      }
      throw 'Dio error: ${e.message}';
    } catch (e) {
      throw 'Unexpected error: $e';
    }
  }

  // Get all patient profiles (admin only)
  Future<List<PatientProfile>> fetchAllPatients() async {
    try {
      final res = await _apiClient.get('/profile');

      // Defensive type check before parsing
      if (res.data is List) {
        final List<dynamic> data = res.data;
        return data
            .map((e) => PatientProfile.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw 'Unexpected response format';
      }
    } on DioError catch (e) {
      final errorData = e.response?.data;

      if (errorData is Map<String, dynamic>) {
        final message = errorData['message'];
        if (message is String) {
          throw 'Failed to fetch patients: $message';
        } else if (message is List && message.isNotEmpty) {
          throw 'Failed to fetch patients: ${message.first}';
        } else if (message is Map) {
          throw jsonEncode(message);
        } else {
          throw 'Failed to fetch patients: Unexpected error format';
        }
      }

      // fallback error message
      throw 'Failed to fetch patients: ${e.message}';
    } catch (e) {
      throw 'Fetching patients failed: ${e.toString()}';
    }
  }

  // Update a specific patient profile (by ID)
  Future<void> updatePatientProfile(int id, PatientProfile updated) async {
    try {
      await _apiClient.patch('/profile/$id', data: updated.toJson());
    } on DioError catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        final message = errorData['message'];
        if (message is String) {
          throw message;
        } else if (message is List && message.isNotEmpty) {
          throw message.first.toString();
        } else if (message is Map) {
          throw jsonEncode(message);
        } else {
          throw 'Update failed unexpectedly';
        }
      }
      throw 'Update request failed: ${e.message}';
    } catch (e) {
      throw 'Updating patient profile failed: ${e.toString()}';
    }
  }
}
