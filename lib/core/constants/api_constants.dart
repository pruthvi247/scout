import '../config/app_config.dart';

class ApiConstants {
  // Base URL - Configured via AppConfig
  // See lib/core/config/app_config.dart to change for your environment
  static String get baseUrl => AppConfig.getBaseUrl();

  // API Version
  static const String apiPrefix = '/api';

  // Auth Endpoints
  static const String authLogin = '$apiPrefix/auth/login';
  static const String authRegister = '$apiPrefix/auth/register';
  static const String authMe = '$apiPrefix/auth/me';
  static const String authRefresh = '$apiPrefix/auth/refresh';
  static const String authLogout = '$apiPrefix/auth/logout';

  // Users Endpoints
  static const String users = '$apiPrefix/users';
  static String userById(int id) => '$users/$id';
  static String userActivities(int id) => '$users/$id/activities';
  static String userActivate(int id) => '$users/$id/activate';

  // Activities Endpoints
  static const String activities = '$apiPrefix/activities';
  static String activityById(int id) => '$activities/$id';
  static String activityVerify(int id) => '$activities/$id/verify';
  static String activityReject(int id) => '$activities/$id/reject';
  static const String activitiesExport = '$activities/export';

  // Organization Endpoints
  static const String organizationTree = '$apiPrefix/organization/tree';
  static const String organizationNodes = '$apiPrefix/organization/nodes';
  static String organizationNodeById(int id) => '$organizationNodes/$id';
  static String organizationNodeMembers(int id) =>
      '$organizationNodes/$id/members';
  static String organizationNodeActivities(int id) =>
      '$organizationNodes/$id/activities';
  static String organizationNodeAssignMember(int id) =>
      '$organizationNodes/$id/assign-member';

  // Dashboard Endpoints
  static const String dashboardStats = '$apiPrefix/dashboard/stats';
  static const String dashboardMembers = '$apiPrefix/dashboard/members';
  static const String dashboardActivities = '$apiPrefix/dashboard/activities';
  static const String dashboardEngagement = '$apiPrefix/dashboard/engagement';
  static const String dashboardPendingReports =
      '$apiPrefix/dashboard/pending-reports';
  static const String dashboardExport = '$apiPrefix/dashboard/export';

  // Notifications Endpoints
  static const String notifications = '$apiPrefix/notifications';
  static String notificationById(int id) => '$notifications/$id';
  static String notificationSend(int id) => '$notifications/$id/send';
  static String notificationMarkRead(int id) => '$notifications/$id/mark-read';
  static const String notificationsUnread = '$notifications/unread';

  // Volunteers Endpoints
  static const String volunteers = '$apiPrefix/volunteers';
  static String volunteerById(int id) => '$volunteers/$id';
  static String volunteerAssignments(int id) => '$volunteers/$id/assignments';
  static String volunteerAssignmentById(int volunteerId, int assignmentId) =>
      '$volunteers/$volunteerId/assignments/$assignmentId';
  static String volunteerScore(int id) => '$volunteers/$id/score';
  static String volunteerPerformance(int id) => '$volunteers/$id/performance';

  // Events Endpoints
  static const String events = '$apiPrefix/events';
  static String eventById(int id) => '$events/$id';
  static String eventAssignVolunteers(int id) =>
      '$events/$id/assign-volunteers';
  static String eventAttendance(int id) => '$events/$id/attendance';

  // Feedback Endpoints
  static const String feedback = '$apiPrefix/feedback';
  static String feedbackById(int id) => '$feedback/$id';
  static String feedbackAssign(int id) => '$feedback/$id/assign';
  static String feedbackResolve(int id) => '$feedback/$id/resolve';
  static const String feedbackStats = '$feedback/stats';

  // Content Endpoints
  static const String content = '$apiPrefix/content';
  static String contentById(int id) => '$content/$id';
  static String contentPublish(int id) => '$content/$id/publish';
  static String contentUnpublish(int id) => '$content/$id/unpublish';

  // Upload Endpoints
  static const String upload = '$apiPrefix/upload';
  static String deleteUpload(String filePath) => '$upload/$filePath';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
