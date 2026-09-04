import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';
import '../../models/activity_model.dart';
import '../utils/app_logger.dart';

/// API service for activity-related operations
class ActivityApiService {
  final Dio _dio;
  final Logger _logger = Logger();

  ActivityApiService(this._dio);

  /// Create a new activity
  Future<Activity> createActivity(CreateActivityRequest request) async {
    try {
      final requestData = request.toJson();
      appLogger.info('Creating activity: ${request.title}', tag: 'ActivityAPI');
      appLogger.debug('Request data', tag: 'ActivityAPI', data: requestData);

      final response = await _dio.post(
        ApiConstants.activities,
        data: requestData,
      );

      appLogger.info('Activity created successfully', tag: 'ActivityAPI');
      return Activity.fromJson(response.data);
    } on DioException catch (e) {
      appLogger.error(
        'Failed to create activity',
        tag: 'ActivityAPI',
        error: e,
        stackTrace: e.stackTrace,
      );
      throw _handleError(e);
    }
  }

  /// Get list of activities with optional filters
  Future<List<Activity>> getActivities({
    String? status,
    String? activityType,
    String? organizationLevel,
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (status != null) queryParams['status'] = status;
      if (activityType != null) queryParams['activity_type'] = activityType;
      if (organizationLevel != null) {
        queryParams['organization_level'] = organizationLevel;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (userId != null) queryParams['user_id'] = userId;

      appLogger.debug(
        'Fetching activities',
        tag: 'ActivityAPI',
        data: queryParams,
      );

      final response = await _dio.get(
        ApiConstants.activities,
        queryParameters: queryParams,
      );

      final activities = (response.data['items'] as List)
          .map((json) => Activity.fromJson(json))
          .toList();

      appLogger.info(
        'Fetched ${activities.length} activities',
        tag: 'ActivityAPI',
      );

      return activities;
    } on DioException catch (e) {
      appLogger.error(
        'Failed to fetch activities',
        tag: 'ActivityAPI',
        error: e,
        stackTrace: e.stackTrace,
      );
      throw _handleError(e);
    } catch (e, stackTrace) {
      appLogger.error(
        'Unexpected error fetching activities',
        tag: 'ActivityAPI',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get activity by ID
  Future<Activity> getActivityById(int id) async {
    try {
      _logger.d('Fetching activity: $id');
      final response = await _dio.get(ApiConstants.activityById(id));
      _logger.i('Activity fetched successfully');
      return Activity.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('Failed to fetch activity: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Update activity
  Future<Activity> updateActivity(int id, UpdateActivityRequest request) async {
    try {
      _logger.d('Updating activity: $id');
      final response = await _dio.put(
        ApiConstants.activityById(id),
        data: request.toJson(),
      );
      _logger.i('Activity updated successfully');
      return Activity.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('Failed to update activity: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Delete activity
  Future<void> deleteActivity(int id) async {
    try {
      _logger.d('Deleting activity: $id');
      await _dio.delete(ApiConstants.activityById(id));
      _logger.i('Activity deleted successfully');
    } on DioException catch (e) {
      _logger.e('Failed to delete activity: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Verify activity (admin/incharge only)
  Future<Activity> verifyActivity(int id) async {
    try {
      _logger.d('Verifying activity: $id');
      final response = await _dio.post(ApiConstants.activityVerify(id));
      _logger.i('Activity verified successfully');
      return Activity.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('Failed to verify activity: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Reject activity (admin/incharge only)
  Future<Activity> rejectActivity(int id, String reason) async {
    try {
      _logger.d('Rejecting activity: $id');
      final response = await _dio.post(
        ApiConstants.activityReject(id),
        data: {'reason': reason},
      );
      _logger.i('Activity rejected successfully');
      return Activity.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('Failed to reject activity: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Upload media files for activity
  Future<List<String>> uploadMediaFiles(List<String> filePaths) async {
    try {
      _logger.d('Uploading ${filePaths.length} media files');
      final uploadedPaths = <String>[];

      for (final filePath in filePaths) {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath),
        });

        final response = await _dio.post(ApiConstants.upload, data: formData);

        uploadedPaths.add(response.data['file_path']);
      }

      _logger.i('Uploaded ${uploadedPaths.length} media files');
      return uploadedPaths;
    } on DioException catch (e) {
      _logger.e('Failed to upload media files: ${e.message}');
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
