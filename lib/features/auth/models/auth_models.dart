import 'dart:convert';
import 'dart:convert' show utf8;
import 'package:base64/base64.dart';

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;

  RegisterRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String role;
  final String userId;
  final String email;

  AuthResponse({
    required this.accessToken,
    required this.role,
    required this.userId,
    required this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      if (json['token'] == null || json['token']['access_token'] == null) {
        throw Exception('Access token is missing in the response');
      }

      final token = json['token']['access_token'];
      
      // For login response
      if (json['user'] == null) {
        final parts = token.split('.');
        if (parts.length != 3) {
          throw Exception('Invalid token format');
        }
        
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final userData = jsonDecode(decoded);

        return AuthResponse(
          accessToken: token,
          role: userData['role'],
          userId: userData['sub'].toString(),
          email: userData['email'],
        );
      }

      // For registration response
      if (json['user']['id'] == null) {
        throw Exception('User ID is missing in the response');
      }
      if (json['user']['email'] == null) {
        throw Exception('User email is missing in the response');
      }
      if (json['user']['role'] == null) {
        throw Exception('User role is missing in the response');
      }

      return AuthResponse(
        accessToken: json['token']['access_token'],
        role: json['user']['role'],
        userId: json['user']['id'].toString(),
        email: json['user']['email'],
      );
    } catch (e) {
      print('Error parsing AuthResponse: $e');
      print('Response data: $json');
      rethrow;
    }
  }
}

class CreateProfileRequest {
  final String name;
  final String dateOfBirth;
  final String gender;
  final double? height;
  final double? weight;
  final String? bloodType;
  final String? emergencyContactRelation;

  CreateProfileRequest({
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.height,
    this.weight,
    this.bloodType,
    this.emergencyContactRelation,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'height': height,
      'weight': weight,
      'bloodType': bloodType,
      'emergencyContactRelation': emergencyContactRelation,
    };
  }
} 