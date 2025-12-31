import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';
import '../../models/user_model.dart';
import '../../models/activity_model.dart';

/// API service for user-related operations
class UserApiService {
  final Dio _dio;
  final Logger _logger = Logger();

  UserApiService(this._dio);

  /// Get list of users with optional filters
  Future<List<User>> getUsers({
    String? role,
    String? organizationLevel,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _logger.d('Fetching users (page: $page, limit: $limit)');
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (role != null) queryParams['role'] = role;
      if (organizationLevel != null) {
        queryParams['organization_level'] = organizationLevel;
      }
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await _dio.get(
        ApiConstants.users,
        queryParameters: queryParams,
      );

      _logger.i('Fetched ${response.data.length} users');
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } on DioException catch (e) {
      _logger.e('Failed to fetch users: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Get user by ID
  Future<User> getUserById(int id) async {
    try {
      _logger.d('Fetching user: $id');
      final response = await _dio.get(ApiConstants.userById(id));
      _logger.i('User fetched successfully');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('Failed to fetch user: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Get user's activities
  Future<List<Activity>> getUserActivities(int userId) async {
    try {
      _logger.d('Fetching activities for user: $userId');
      final response = await _dio.get(ApiConstants.userActivities(userId));
      _logger.i('Fetched ${response.data.length} activities');
      return (response.data as List)
          .map((json) => Activity.fromJson(json))
          .toList();
    } on DioException catch (e) {
      _logger.e('Failed to fetch user activities: ${e.message}');
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;

      if (data is Map && data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is List) {
          return detail.map((e) => e['msg'] ?? e.toString()).join(', ');
        }
        return detail.toString();
      }

      if (data is String) {
        return 'Server error (${e.response!.statusCode}): $data';
      }

      return 'Server error: ${e.response!.statusCode}';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Connection failed. Please check your internet connection.';
    }
    return 'An unexpected error occurred';
  }
}
