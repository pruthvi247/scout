import 'package:json_annotation/json_annotation.dart';

part 'volunteer_model.g.dart';

@JsonSerializable()
class VolunteerProfile {
  final int id;
  final int userId;
  final List<Assignment> assignments;
  final List<int> events;
  final List<AttendanceRecord> attendanceRecords;
  final double performanceScore;
  final List<PerformanceHistory> performanceHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  VolunteerProfile({
    required this.id,
    required this.userId,
    required this.assignments,
    required this.events,
    required this.attendanceRecords,
    required this.performanceScore,
    required this.performanceHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VolunteerProfile.fromJson(Map<String, dynamic> json) =>
      _$VolunteerProfileFromJson(json);

  Map<String, dynamic> toJson() => _$VolunteerProfileToJson(this);
}

@JsonSerializable()
class Assignment {
  final int assignmentId;
  final String title;
  final String description;
  final String status; // pending, in_progress, completed, cancelled
  final DateTime assignedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;

  Assignment({
    required this.assignmentId,
    required this.title,
    required this.description,
    required this.status,
    required this.assignedAt,
    this.dueDate,
    this.completedAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentToJson(this);
}

@JsonSerializable()
class AttendanceRecord {
  final int eventId;
  final bool attended;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  AttendanceRecord({
    required this.eventId,
    required this.attended,
    this.checkInTime,
    this.checkOutTime,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceRecordToJson(this);
}

@JsonSerializable()
class PerformanceHistory {
  final DateTime date;
  final double score;
  final String? notes;

  PerformanceHistory({
    required this.date,
    required this.score,
    this.notes,
  });

  factory PerformanceHistory.fromJson(Map<String, dynamic> json) =>
      _$PerformanceHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceHistoryToJson(this);
}

@JsonSerializable()
class Event {
  final int id;
  final String title;
  final String description;
  final String eventType;
  final EventLocation location;
  final DateTime startTime;
  final DateTime endTime;
  final List<int> assignedVolunteers;
  final int attendanceCount;
  final int createdBy;
  final String status; // scheduled, ongoing, completed, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.eventType,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.assignedVolunteers,
    required this.attendanceCount,
    required this.createdBy,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}

@JsonSerializable()
class EventLocation {
  final double? lat;
  final double? lng;
  final String address;

  EventLocation({
    this.lat,
    this.lng,
    required this.address,
  });

  factory EventLocation.fromJson(Map<String, dynamic> json) =>
      _$EventLocationFromJson(json);

  Map<String, dynamic> toJson() => _$EventLocationToJson(this);
}

@JsonSerializable()
class CreateAssignmentRequest {
  final String title;
  final String description;
  final DateTime? dueDate;

  CreateAssignmentRequest({
    required this.title,
    required this.description,
    this.dueDate,
  });

  factory CreateAssignmentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAssignmentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAssignmentRequestToJson(this);
}

@JsonSerializable()
class CreateEventRequest {
  final String title;
  final String description;
  final String eventType;
  final EventLocation location;
  final DateTime startTime;
  final DateTime endTime;
  final List<int>? assignedVolunteers;

  CreateEventRequest({
    required this.title,
    required this.description,
    required this.eventType,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.assignedVolunteers,
  });

  factory CreateEventRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateEventRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateEventRequestToJson(this);
}
