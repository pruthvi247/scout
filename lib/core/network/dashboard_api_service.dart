import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';
import '../../models/dashboard_model.dart';

class DashboardApiService {
  final Dio _dio;
  final Logger _logger = Logger();

  DashboardApiService(this._dio);

  // Get dashboard statistics
  Future<DashboardStats> getDashboardStats({
    String? organizationLevel,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (organizationLevel != null) {
        queryParams['organizationLevel'] = organizationLevel;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      _logger.d('Fetching dashboard stats with params: $queryParams');

      final response = await _dio.get(
        ApiConstants.dashboardStats,
        queryParameters: queryParams,
      );

      _logger.d('Dashboard stats response: ${response.data}');
      return DashboardStats.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching dashboard stats: $e');
      rethrow;
    }
  }

  // Get member statistics
  Future<MemberStats> getMemberStats({
    String? organizationLevel,
    String? role,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (organizationLevel != null) {
        queryParams['organizationLevel'] = organizationLevel;
      }
      if (role != null) {
        queryParams['role'] = role;
      }

      _logger.d('Fetching member stats with params: $queryParams');

      final response = await _dio.get(
        ApiConstants.dashboardMembers,
        queryParameters: queryParams,
      );

      _logger.d('Member stats response: ${response.data}');
      return MemberStats.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching member stats: $e');
      rethrow;
    }
  }

  // Get engagement metrics
  Future<EngagementMetrics> getEngagementMetrics({
    String? organizationLevel,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (organizationLevel != null) {
        queryParams['organizationLevel'] = organizationLevel;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      _logger.d('Fetching engagement metrics with params: $queryParams');

      final response = await _dio.get(
        ApiConstants.dashboardEngagement,
        queryParameters: queryParams,
      );

      _logger.d('Engagement metrics response: ${response.data}');
      return EngagementMetrics.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching engagement metrics: $e');
      rethrow;
    }
  }

  // Export dashboard data
  Future<String> exportDashboardData({
    String format = 'csv', // csv or json
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'format': format,
      };
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      _logger.d('Exporting dashboard data with params: $queryParams');

      final response = await _dio.get(
        ApiConstants.dashboardExport,
        queryParameters: queryParams,
      );

      _logger.d('Export response: ${response.data}');
      return response.data['downloadUrl'] ?? response.data['data'];
    } catch (e) {
      _logger.e('Error exporting dashboard data: $e');
      rethrow;
    }
  }
}
