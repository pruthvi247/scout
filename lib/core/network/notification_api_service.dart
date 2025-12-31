import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';
import '../../models/notification_model.dart';

class NotificationApiService {
  final Dio _dio;
  final Logger _logger = Logger();

  NotificationApiService(this._dio);

  // Get notifications list
  Future<Map<String, dynamic>> getNotifications({
    String? type,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;

      _logger.d('Fetching notifications with params: $queryParams');

      final response = await _dio.get(
        ApiConstants.notifications,
        queryParameters: queryParams,
      );

      _logger.d('Notifications response: ${response.data}');

      return {
        'notifications': (response.data['notifications'] as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList(),
        'total': response.data['total'] ?? 0,
        'hasMore': response.data['hasMore'] ?? false,
      };
    } catch (e) {
      _logger.e('Error fetching notifications: $e');
      rethrow;
    }
  }

  // Get notification by ID
  Future<NotificationModel> getNotificationById(int id) async {
    try {
      _logger.d('Fetching notification by ID: $id');

      final response = await _dio.get('${ApiConstants.notifications}/$id');

      _logger.d('Notification response: ${response.data}');
      return NotificationModel.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching notification $id: $e');
      rethrow;
    }
  }

  // Create notification
  Future<NotificationModel> createNotification(
      CreateNotificationRequest request) async {
    try {
      _logger.d('Creating notification: ${request.toJson()}');

      final response = await _dio.post(
        ApiConstants.notifications,
        data: request.toJson(),
      );

      _logger.d('Create notification response: ${response.data}');
      return NotificationModel.fromJson(response.data);
    } catch (e) {
      _logger.e('Error creating notification: $e');
      rethrow;
    }
  }

  // Update notification
  Future<NotificationModel> updateNotification(
      int id, Map<String, dynamic> updates) async {
    try {
      _logger.d('Updating notification $id: $updates');

      final response = await _dio.put(
        '${ApiConstants.notifications}/$id',
        data: updates,
      );

      _logger.d('Update notification response: ${response.data}');
      return NotificationModel.fromJson(response.data);
    } catch (e) {
      _logger.e('Error updating notification $id: $e');
      rethrow;
    }
  }

  // Delete notification
  Future<void> deleteNotification(int id) async {
    try {
      _logger.d('Deleting notification: $id');

      await _dio.delete('${ApiConstants.notifications}/$id');

      _logger.d('Notification deleted successfully');
    } catch (e) {
      _logger.e('Error deleting notification $id: $e');
      rethrow;
    }
  }

  // Send notification
  Future<void> sendNotification(int id) async {
    try {
      _logger.d('Sending notification: $id');

      await _dio.post('${ApiConstants.notifications}/$id/send');

      _logger.d('Notification sent successfully');
    } catch (e) {
      _logger.e('Error sending notification $id: $e');
      rethrow;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(int id) async {
    try {
      _logger.d('Marking notification as read: $id');

      await _dio.post('${ApiConstants.notifications}/$id/mark-read');

      _logger.d('Notification marked as read');
    } catch (e) {
      _logger.e('Error marking notification as read $id: $e');
      rethrow;
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      _logger.d('Fetching unread notifications count');

      final response = await _dio.get('${ApiConstants.notifications}/unread');

      _logger.d('Unread count response: ${response.data}');
      return response.data['count'] ?? 0;
    } catch (e) {
      _logger.e('Error fetching unread count: $e');
      rethrow;
    }
  }
}
