import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';
import '../../models/volunteer_model.dart';

class VolunteerApiService {
  final Dio _dio;
  final Logger _logger = Logger();

  VolunteerApiService(this._dio);

  // Get volunteers list
  Future<Map<String, dynamic>> getVolunteers({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      _logger.d('Fetching volunteers with params: $queryParams');

      final response = await _dio.get(
        ApiConstants.volunteers,
        queryParameters: queryParams,
      );

      _logger.d('Volunteers response: ${response.data}');

      return {
        'volunteers': (response.data['volunteers'] as List)
            .map((json) => VolunteerProfile.fromJson(json))
            .toList(),
        'total': response.data['total'] ?? 0,
        'hasMore': response.data['hasMore'] ?? false,
      };
    } catch (e) {
      _logger.e('Error fetching volunteers: $e');
      rethrow;
    }
  }

  // Get volunteer by ID
  Future<VolunteerProfile> getVolunteerById(int id) async {
    try {
      _logger.d('Fetching volunteer by ID: $id');

      final response = await _dio.get('${ApiConstants.volunteers}/$id');

      _logger.d('Volunteer response: ${response.data}');
      return VolunteerProfile.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching volunteer $id: $e');
      rethrow;
    }
  }

  // Create assignment for volunteer
  Future<Assignment> createAssignment(
      int volunteerId, CreateAssignmentRequest request) async {
    try {
      _logger.d('Creating assignment for volunteer $volunteerId: ${request.toJson()}');

      final response = await _dio.post(
        '${ApiConstants.volunteers}/$volunteerId/assignments',
        data: request.toJson(),
      );

      _logger.d('Create assignment response: ${response.data}');
      return Assignment.fromJson(response.data);
    } catch (e) {
      _logger.e('Error creating assignment for volunteer $volunteerId: $e');
      rethrow;
    }
  }

  // Get assignments for volunteer
  Future<List<Assignment>> getAssignments(int volunteerId) async {
    try {
      _logger.d('Fetching assignments for volunteer: $volunteerId');

      final response = await _dio.get(
        '${ApiConstants.volunteers}/$volunteerId/assignments',
      );

      _logger.d('Assignments response: ${response.data}');
      return (response.data as List)
          .map((json) => Assignment.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Error fetching assignments for volunteer $volunteerId: $e');
      rethrow;
    }
  }

  // Update assignment
  Future<Assignment> updateAssignment(
      int volunteerId, int assignmentId, Map<String, dynamic> updates) async {
    try {
      _logger.d('Updating assignment $assignmentId for volunteer $volunteerId: $updates');

      final response = await _dio.put(
        '${ApiConstants.volunteers}/$volunteerId/assignments/$assignmentId',
        data: updates,
      );

      _logger.d('Update assignment response: ${response.data}');
      return Assignment.fromJson(response.data);
    } catch (e) {
      _logger.e('Error updating assignment $assignmentId: $e');
      rethrow;
    }
  }

  // Update performance score
  Future<void> updatePerformanceScore(int volunteerId, double score,
      {String? notes}) async {
    try {
      _logger.d('Updating performance score for volunteer $volunteerId: $score');

      await _dio.post(
        '${ApiConstants.volunteers}/$volunteerId/score',
        data: {'score': score, 'notes': notes},
      );

      _logger.d('Performance score updated successfully');
    } catch (e) {
      _logger.e('Error updating performance score for volunteer $volunteerId: $e');
      rethrow;
    }
  }

  // Get performance history
  Future<List<PerformanceHistory>> getPerformanceHistory(
      int volunteerId) async {
    try {
      _logger.d('Fetching performance history for volunteer: $volunteerId');

      final response = await _dio.get(
        '${ApiConstants.volunteers}/$volunteerId/performance',
      );

      _logger.d('Performance history response: ${response.data}');
      return (response.data as List)
          .map((json) => PerformanceHistory.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Error fetching performance history for volunteer $volunteerId: $e');
      rethrow;
    }
  }

  // ============ Events ============

  // Get events list
  Future<Map<String, dynamic>> getEvents({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) queryParams['status'] = status;

      _logger.d('Fetching events with params: $queryParams');

      final response = await _dio.get(
        ApiConstants.events,
        queryParameters: queryParams,
      );

      _logger.d('Events response: ${response.data}');

      return {
        'events': (response.data['events'] as List)
            .map((json) => Event.fromJson(json))
            .toList(),
        'total': response.data['total'] ?? 0,
        'hasMore': response.data['hasMore'] ?? false,
      };
    } catch (e) {
      _logger.e('Error fetching events: $e');
      rethrow;
    }
  }

  // Get event by ID
  Future<Event> getEventById(int id) async {
    try {
      _logger.d('Fetching event by ID: $id');

      final response = await _dio.get('${ApiConstants.events}/$id');

      _logger.d('Event response: ${response.data}');
      return Event.fromJson(response.data);
    } catch (e) {
      _logger.e('Error fetching event $id: $e');
      rethrow;
    }
  }

  // Create event
  Future<Event> createEvent(CreateEventRequest request) async {
    try {
      _logger.d('Creating event: ${request.toJson()}');

      final response = await _dio.post(
        ApiConstants.events,
        data: request.toJson(),
      );

      _logger.d('Create event response: ${response.data}');
      return Event.fromJson(response.data);
    } catch (e) {
      _logger.e('Error creating event: $e');
      rethrow;
    }
  }

  // Update event
  Future<Event> updateEvent(int id, Map<String, dynamic> updates) async {
    try {
      _logger.d('Updating event $id: $updates');

      final response = await _dio.put(
        '${ApiConstants.events}/$id',
        data: updates,
      );

      _logger.d('Update event response: ${response.data}');
      return Event.fromJson(response.data);
    } catch (e) {
      _logger.e('Error updating event $id: $e');
      rethrow;
    }
  }

  // Delete event
  Future<void> deleteEvent(int id) async {
    try {
      _logger.d('Deleting event: $id');

      await _dio.delete('${ApiConstants.events}/$id');

      _logger.d('Event deleted successfully');
    } catch (e) {
      _logger.e('Error deleting event $id: $e');
      rethrow;
    }
  }

  // Assign volunteers to event
  Future<void> assignVolunteers(int eventId, List<int> volunteerIds) async {
    try {
      _logger.d('Assigning volunteers to event $eventId: $volunteerIds');

      await _dio.post(
        '${ApiConstants.events}/$eventId/assign-volunteers',
        data: {'volunteerIds': volunteerIds},
      );

      _logger.d('Volunteers assigned successfully');
    } catch (e) {
      _logger.e('Error assigning volunteers to event $eventId: $e');
      rethrow;
    }
  }

  // Record attendance
  Future<void> recordAttendance(
      int eventId, int volunteerId, bool attended) async {
    try {
      _logger.d('Recording attendance for event $eventId, volunteer $volunteerId: $attended');

      await _dio.post(
        '${ApiConstants.events}/$eventId/attendance',
        data: {
          'volunteerId': volunteerId,
          'attended': attended,
          'checkInTime': attended ? DateTime.now().toIso8601String() : null,
        },
      );

      _logger.d('Attendance recorded successfully');
    } catch (e) {
      _logger.e('Error recording attendance: $e');
      rethrow;
    }
  }

  // Get attendance list
  Future<List<AttendanceRecord>> getAttendance(int eventId) async {
    try {
      _logger.d('Fetching attendance for event: $eventId');

      final response = await _dio.get(
        '${ApiConstants.events}/$eventId/attendance',
      );

      _logger.d('Attendance response: ${response.data}');
      return (response.data as List)
          .map((json) => AttendanceRecord.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Error fetching attendance for event $eventId: $e');
      rethrow;
    }
  }
}
