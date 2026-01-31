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

      // Handle the actual API response format with safe defaults
      // Backend API returns: total_members, recent_activities, pending_reports, verified_activities, engagement_level
      final data = response.data as Map<String, dynamic>;

      return DashboardStats(
        totalMembers: (data['total_members'] as num? ?? 0).toInt(),
        totalActivities: (data['recent_activities'] as num? ?? 0)
            .toInt(), // Backend uses 'recent_activities'
        pendingActivities: (data['pending_reports'] as num? ?? 0)
            .toInt(), // Backend uses 'pending_reports'
        verifiedActivities: (data['verified_activities'] as num? ?? 0).toInt(),
        rejectedActivities: (data['rejected_activities'] as num? ?? 0).toInt(),
        organizationNodes: (data['organization_nodes'] as num? ?? 0).toInt(),
        activeVolunteers: (data['active_volunteers'] as num? ?? 0).toInt(),
        pendingFeedback: (data['pending_feedback'] as num? ?? 0).toInt(),
        activitiesByType: _parseIntMap(data['activities_by_type']),
        membersByRole: _parseIntMap(data['members_by_role']),
        activitiesByStatus: _parseIntMap(data['activities_by_status']),
        activityTrends: _parseActivityTrends(data['activity_trends']),
      );
    } catch (e) {
      _logger.e('Error fetching dashboard stats: $e');
      rethrow;
    }
  }

  Map<String, int>? _parseIntMap(dynamic data) {
    if (data == null) return null;
    if (data is! Map) return null;

    return data.map(
      (key, value) => MapEntry(key.toString(), (value as num?)?.toInt() ?? 0),
    );
  }

  List<ActivityTrend>? _parseActivityTrends(dynamic data) {
    if (data == null) return null;
    if (data is! List) return null;

    return data
        .map((item) {
          if (item is! Map<String, dynamic>) return null;
          return ActivityTrend.fromJson(item);
        })
        .whereType<ActivityTrend>()
        .toList();
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

      // Handle the actual API response format
      final data = response.data as Map<String, dynamic>;

      // Extract by_role data
      final byRole = data['by_role'] as Map<String, dynamic>? ?? {};
      final membersByRole = byRole.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      );

      // Calculate totals
      final totalMembers = membersByRole.values.fold(
        0,
        (sum, count) => sum + count,
      );

      // Create MemberStats with calculated values
      return MemberStats(
        totalMembers: totalMembers,
        activeMembers: totalMembers, // Assume all are active for now
        inactiveMembers: 0,
        membersByRole: membersByRole,
        membersByLevel: {}, // Empty for now
        topPerformers: null,
      );
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

      // Handle the actual API response format with safe defaults
      final data = response.data as Map<String, dynamic>;

      return EngagementMetrics(
        averageActivitiesPerMember:
            (data['average_activities_per_member'] as num? ?? 0).toDouble(),
        activityCompletionRate: (data['activity_completion_rate'] as num? ?? 0)
            .toDouble(),
        totalCheckIns: (data['total_check_ins'] as num? ?? 0).toInt(),
        activitiesByRegion: _parseIntMap(data['activities_by_region']) ?? {},
        regionEngagement: _parseRegionEngagement(data['region_engagement']),
      );
    } catch (e) {
      _logger.e('Error fetching engagement metrics: $e');
      rethrow;
    }
  }

  List<RegionEngagement>? _parseRegionEngagement(dynamic data) {
    if (data == null) return null;
    if (data is! List) return null;

    return data
        .map((item) {
          if (item is! Map<String, dynamic>) return null;
          return RegionEngagement.fromJson(item);
        })
        .whereType<RegionEngagement>()
        .toList();
  }

  // Export dashboard data
  Future<String> exportDashboardData({
    String format = 'csv', // csv or json
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{'format': format};
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
