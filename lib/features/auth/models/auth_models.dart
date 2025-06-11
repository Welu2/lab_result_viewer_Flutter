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
  final User user;
  final Token token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      token: Token.fromJson(json['token']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token.toJson(),
    };
  }
}

class User {
  final int id;
  final String? patientId;
  final String email;
  final String role;

  User({
    required this.id,
    this.patientId,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      patientId: json['patientId'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'email': email,
      'role': role,
    };
  }
}

class Token {
  final String accessToken;

  Token({
    required this.accessToken,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
    };
  }
}

class CreateProfileRequest {
  final String name;
  final String dateOfBirth;
  final String gender;
  final double? height;
  final double? weight;
  final String? bloodType;
  final String? phoneNumber;

  CreateProfileRequest({
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.height,
    this.weight,
    this.bloodType,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth,
      'gender': gender.toLowerCase(),
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (bloodType != null) 'bloodType': bloodType,
      if (phoneNumber != null && phoneNumber!.isNotEmpty) 'phoneNumber': phoneNumber,
    };
  }
}

class ProfileResponse {
  final int id;
  final String name;
  final String dateOfBirth;
  final String gender;
  final double? weight;
  final double? height;
  final String? bloodType;
  final String? phoneNumber;
  final User user;
  final String patientId;

  ProfileResponse({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.weight,
    this.height,
    this.bloodType,
    this.phoneNumber,
    required this.user,
    required this.patientId,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      gender: json['gender'] as String,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      bloodType: json['bloodType'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      patientId: json['patientId'] as String,
    );
  }
}

class LoginResponse {
  final String message;
  final Token token;

  LoginResponse({
    required this.message,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] as String,
      token: Token.fromJson(json['token'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token.toJson(),
    };
  }
} 