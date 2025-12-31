import 'package:json_annotation/json_annotation.dart';

part 'activity_model.g.dart';

@JsonSerializable()
class Activity {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'activity_type')
  final String activityType;
  final String title;
  final String description;
  final ActivityLocation location;
  @JsonKey(name: 'check_in_time')
  final DateTime checkInTime;
  @JsonKey(name: 'media_files')
  final List<String>? mediaFiles;
  final String status;
  @JsonKey(name: 'verified_by')
  final int? verifiedBy;
  @JsonKey(name: 'verified_at')
  final DateTime? verifiedAt;
  @JsonKey(name: 'organization_level')
  final String organizationLevel;
  final List<String>? tags;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Activity({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.title,
    required this.description,
    required this.location,
    required this.checkInTime,
    this.mediaFiles,
    required this.status,
    this.verifiedBy,
    this.verifiedAt,
    required this.organizationLevel,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}

@JsonSerializable()
class ActivityLocation {
  final double lat;
  final double lng;
  final String address;

  ActivityLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  factory ActivityLocation.fromJson(Map<String, dynamic> json) =>
      _$ActivityLocationFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityLocationToJson(this);
}

@JsonSerializable()
class CreateActivityRequest {
  @JsonKey(name: 'activity_type')
  final String activityType;
  final String title;
  final String description;
  final ActivityLocation location;
  @JsonKey(name: 'check_in_time')
  final DateTime checkInTime;
  @JsonKey(name: 'organization_level')
  final String organizationLevel;
  final List<String>? tags;

  CreateActivityRequest({
    required this.activityType,
    required this.title,
    required this.description,
    required this.location,
    required this.checkInTime,
    required this.organizationLevel,
    this.tags,
  });

  factory CreateActivityRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateActivityRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateActivityRequestToJson(this);
}

@JsonSerializable()
class UpdateActivityRequest {
  final String? title;
  final String? description;
  final ActivityLocation? location;
  @JsonKey(name: 'check_in_time')
  final DateTime? checkInTime;
  final List<String>? tags;

  UpdateActivityRequest({
    this.title,
    this.description,
    this.location,
    this.checkInTime,
    this.tags,
  });

  factory UpdateActivityRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateActivityRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateActivityRequestToJson(this);
}

@JsonSerializable()
class ActivityListResponse {
  final List<Activity> items;
  final int total;
  final int skip;
  final int limit;

  ActivityListResponse({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ActivityListResponse.fromJson(Map<String, dynamic> json) =>
      _$ActivityListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityListResponseToJson(this);
}
