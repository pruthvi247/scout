import 'package:dio/dio.dart';
import '../../models/user_model.dart';
import '../constants/api_constants.dart';
import '../network/dio_client.dart';

class AuthApiService {
  final DioClient _dioClient;

  AuthApiService(this._dioClient);

  /// Login with username and password
  /// Returns LoginResponse with access token
  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await _dioClient.postFormUrlEncoded(
        ApiConstants.authLogin,
        {'username': username, 'password': password},
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Register a new user
  Future<User> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.authRegister,
        data: request.toJson(),
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.authMe);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh access token
  Future<LoginResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.authRefresh,
        data: {'refresh_token': refreshToken},
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _dioClient.dio.post(ApiConstants.authLogout);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('detail')) {
        return data['detail'].toString();
      }
      return 'Server error: ${error.response!.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please try again.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server.\n\n'
          'Please check:\n'
          '• Backend is running\n'
          '• Correct API URL configured\n'
          '• Network connection\n\n'
          'See NETWORK_SETUP.md for help.';
    } else if (error.type == DioExceptionType.unknown) {
      if (error.error.toString().contains('Connection refused')) {
        return 'Connection refused!\n\n'
            'Backend not reachable. Please:\n'
            '1. Start backend server\n'
            '2. Check API URL in app_config.dart\n'
            '3. See NETWORK_SETUP.md for platform-specific setup';
      }
    }
    return 'An unexpected error occurred: ${error.message}';
  }
}
