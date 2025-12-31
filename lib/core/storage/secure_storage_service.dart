import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data like tokens
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // Storage keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserRole = 'user_role';

  // Token operations
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  // User data operations
  Future<void> saveUserId(int userId) async {
    await _storage.write(key: _keyUserId, value: userId.toString());
  }

  Future<int?> getUserId() async {
    final id = await _storage.read(key: _keyUserId);
    return id != null ? int.tryParse(id) : null;
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _keyUserRole, value: role);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _keyUserRole);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all stored data (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Clear only tokens (for token refresh scenarios)
  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }
}
