import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';
import '../../models/organization_model.dart';

/// API service for organization-related operations
class OrganizationApiService {
  final Dio _dio;
  final Logger _logger = Logger();

  OrganizationApiService(this._dio);

  /// Get full organization tree
  Future<OrganizationTree> getOrganizationTree() async {
    try {
      _logger.d('Fetching organization tree');
      final response = await _dio.get(ApiConstants.organizationTree);
      _logger.i('Organization tree fetched successfully');
      return OrganizationTree.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('Failed to fetch organization tree: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Get list of organization nodes with optional filters
  Future<List<OrganizationNode>> getOrganizationNodes({
    String? type,
    int? parentId,
    bool? isActive,
  }) async {
    try {
      _logger.d('Fetching organization nodes');
      final queryParams = <String, dynamic>{};

      if (type != null) queryParams['type'] = type;
      if (parentId != null) queryParams['parent_id'] = parentId;
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await _dio.get(
        ApiConstants.organizationNodes,
        queryParameters: queryParams,
      );

      _logger.i('Fetched ${response.data.length} organization nodes');
      return (response.data as List)
          .map((json) => OrganizationNode.fromJson(json))
          .toList();
    } on DioException catch (e) {
      _logger.e('Failed to fetch organization nodes: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Get organization node by ID
  Future<OrganizationNode> getOrganizationNodeById(int id) async {
    try {
      _logger.d('Fetching organization node: $id');
      final response = await _dio.get(ApiConstants.organizationNodeById(id));
      _logger.i('Organization node fetched successfully');
      return OrganizationNode.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('Failed to fetch organization node: ${e.message}');
      throw _handleError(e);
    }
  }

  /// Get members in organization node
  Future<List<dynamic>> getNodeMembers(int nodeId) async {
    try {
      _logger.d('Fetching members for node: $nodeId');
      final response = await _dio.get(
        ApiConstants.organizationNodeMembers(nodeId),
      );
      _logger.i('Fetched ${response.data.length} members');
      return response.data as List;
    } on DioException catch (e) {
      _logger.e('Failed to fetch node members: ${e.message}');
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
