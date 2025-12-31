// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  activityType: json['activity_type'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  location: ActivityLocation.fromJson(json['location'] as Map<String, dynamic>),
  checkInTime: DateTime.parse(json['check_in_time'] as String),
  mediaFiles: (json['media_files'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  status: json['status'] as String,
  verifiedBy: (json['verified_by'] as num?)?.toInt(),
  verifiedAt: json['verified_at'] == null
      ? null
      : DateTime.parse(json['verified_at'] as String),
  organizationLevel: json['organization_level'] as String,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'activity_type': instance.activityType,
  'title': instance.title,
  'description': instance.description,
  'location': instance.location.toJson(),
  'check_in_time': instance.checkInTime.toIso8601String(),
  'media_files': instance.mediaFiles,
  'status': instance.status,
  'verified_by': instance.verifiedBy,
  'verified_at': instance.verifiedAt?.toIso8601String(),
  'organization_level': instance.organizationLevel,
  'tags': instance.tags,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

ActivityLocation _$ActivityLocationFromJson(Map<String, dynamic> json) =>
    ActivityLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String,
    );

Map<String, dynamic> _$ActivityLocationToJson(ActivityLocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'address': instance.address,
    };

CreateActivityRequest _$CreateActivityRequestFromJson(
  Map<String, dynamic> json,
) => CreateActivityRequest(
  activityType: json['activity_type'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  location: ActivityLocation.fromJson(json['location'] as Map<String, dynamic>),
  checkInTime: DateTime.parse(json['check_in_time'] as String),
  organizationLevel: json['organization_level'] as String,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$CreateActivityRequestToJson(
  CreateActivityRequest instance,
) => <String, dynamic>{
  'activity_type': instance.activityType,
  'title': instance.title,
  'description': instance.description,
  'location': instance.location.toJson(),
  'check_in_time': instance.checkInTime.toIso8601String(),
  'organization_level': instance.organizationLevel,
  'tags': instance.tags,
};

UpdateActivityRequest _$UpdateActivityRequestFromJson(
  Map<String, dynamic> json,
) => UpdateActivityRequest(
  title: json['title'] as String?,
  description: json['description'] as String?,
  location: json['location'] == null
      ? null
      : ActivityLocation.fromJson(json['location'] as Map<String, dynamic>),
  checkInTime: json['check_in_time'] == null
      ? null
      : DateTime.parse(json['check_in_time'] as String),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$UpdateActivityRequestToJson(
  UpdateActivityRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'location': instance.location?.toJson(),
  'check_in_time': instance.checkInTime?.toIso8601String(),
  'tags': instance.tags,
};

ActivityListResponse _$ActivityListResponseFromJson(
  Map<String, dynamic> json,
) => ActivityListResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => Activity.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  skip: (json['skip'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$ActivityListResponseToJson(
  ActivityListResponse instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'total': instance.total,
  'skip': instance.skip,
  'limit': instance.limit,
};
