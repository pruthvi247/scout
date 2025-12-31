// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volunteer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VolunteerProfile _$VolunteerProfileFromJson(Map<String, dynamic> json) =>
    VolunteerProfile(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      assignments: (json['assignments'] as List<dynamic>)
          .map((e) => Assignment.fromJson(e as Map<String, dynamic>))
          .toList(),
      events: (json['events'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      attendanceRecords: (json['attendance_records'] as List<dynamic>)
          .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      performanceScore: (json['performance_score'] as num).toDouble(),
      performanceHistory: (json['performance_history'] as List<dynamic>)
          .map((e) => PerformanceHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$VolunteerProfileToJson(VolunteerProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'assignments': instance.assignments.map((e) => e.toJson()).toList(),
      'events': instance.events,
      'attendance_records': instance.attendanceRecords
          .map((e) => e.toJson())
          .toList(),
      'performance_score': instance.performanceScore,
      'performance_history': instance.performanceHistory
          .map((e) => e.toJson())
          .toList(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

Assignment _$AssignmentFromJson(Map<String, dynamic> json) => Assignment(
  assignmentId: (json['assignment_id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  status: json['status'] as String,
  assignedAt: DateTime.parse(json['assigned_at'] as String),
  dueDate: json['due_date'] == null
      ? null
      : DateTime.parse(json['due_date'] as String),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
);

Map<String, dynamic> _$AssignmentToJson(Assignment instance) =>
    <String, dynamic>{
      'assignment_id': instance.assignmentId,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'assigned_at': instance.assignedAt.toIso8601String(),
      'due_date': instance.dueDate?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
    };

AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    AttendanceRecord(
      eventId: (json['event_id'] as num).toInt(),
      attended: json['attended'] as bool,
      checkInTime: json['check_in_time'] == null
          ? null
          : DateTime.parse(json['check_in_time'] as String),
      checkOutTime: json['check_out_time'] == null
          ? null
          : DateTime.parse(json['check_out_time'] as String),
    );

Map<String, dynamic> _$AttendanceRecordToJson(AttendanceRecord instance) =>
    <String, dynamic>{
      'event_id': instance.eventId,
      'attended': instance.attended,
      'check_in_time': instance.checkInTime?.toIso8601String(),
      'check_out_time': instance.checkOutTime?.toIso8601String(),
    };

PerformanceHistory _$PerformanceHistoryFromJson(Map<String, dynamic> json) =>
    PerformanceHistory(
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PerformanceHistoryToJson(PerformanceHistory instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'score': instance.score,
      'notes': instance.notes,
    };

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  eventType: json['event_type'] as String,
  location: EventLocation.fromJson(json['location'] as Map<String, dynamic>),
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: DateTime.parse(json['end_time'] as String),
  assignedVolunteers: (json['assigned_volunteers'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  attendanceCount: (json['attendance_count'] as num).toInt(),
  createdBy: (json['created_by'] as num).toInt(),
  status: json['status'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'event_type': instance.eventType,
  'location': instance.location.toJson(),
  'start_time': instance.startTime.toIso8601String(),
  'end_time': instance.endTime.toIso8601String(),
  'assigned_volunteers': instance.assignedVolunteers,
  'attendance_count': instance.attendanceCount,
  'created_by': instance.createdBy,
  'status': instance.status,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

EventLocation _$EventLocationFromJson(Map<String, dynamic> json) =>
    EventLocation(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      address: json['address'] as String,
    );

Map<String, dynamic> _$EventLocationToJson(EventLocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'address': instance.address,
    };

CreateAssignmentRequest _$CreateAssignmentRequestFromJson(
  Map<String, dynamic> json,
) => CreateAssignmentRequest(
  title: json['title'] as String,
  description: json['description'] as String,
  dueDate: json['due_date'] == null
      ? null
      : DateTime.parse(json['due_date'] as String),
);

Map<String, dynamic> _$CreateAssignmentRequestToJson(
  CreateAssignmentRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'due_date': instance.dueDate?.toIso8601String(),
};

CreateEventRequest _$CreateEventRequestFromJson(Map<String, dynamic> json) =>
    CreateEventRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      eventType: json['event_type'] as String,
      location: EventLocation.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      assignedVolunteers: (json['assigned_volunteers'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$CreateEventRequestToJson(CreateEventRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'event_type': instance.eventType,
      'location': instance.location.toJson(),
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'assigned_volunteers': instance.assignedVolunteers,
    };
