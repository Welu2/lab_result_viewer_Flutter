import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';

  Future<void> saveSession({
    required String token,
    required String role,
    required int userId,
    required String email,
  }) async {
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _roleKey, value: role),
      _storage.write(key: _userIdKey, value: userId.toString()),
      _storage.write(key: _emailKey, value: email),
    ]);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _roleKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _emailKey),
    ]);
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<int?> getUserId() async {
    final userIdStr = await _storage.read(key: _userIdKey);
    return userIdStr != null ? int.parse(userIdStr) : null;
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _emailKey);
  }
} 