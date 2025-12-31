// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      targetAudience: json['target_audience'] == null
          ? null
          : TargetAudience.fromJson(
              json['target_audience'] as Map<String, dynamic>,
            ),
      sentVia: (json['sent_via'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: json['status'] as String,
      scheduledAt: json['scheduled_at'] == null
          ? null
          : DateTime.parse(json['scheduled_at'] as String),
      sentAt: json['sent_at'] == null
          ? null
          : DateTime.parse(json['sent_at'] as String),
      createdBy: (json['created_by'] as num).toInt(),
      readBy: (json['read_by'] as List<dynamic>?)
          ?.map((e) => ReadReceipt.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isRead: json['is_read'] as bool?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'target_audience': instance.targetAudience?.toJson(),
      'sent_via': instance.sentVia,
      'status': instance.status,
      'scheduled_at': instance.scheduledAt?.toIso8601String(),
      'sent_at': instance.sentAt?.toIso8601String(),
      'created_by': instance.createdBy,
      'read_by': instance.readBy?.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_read': instance.isRead,
    };

TargetAudience _$TargetAudienceFromJson(Map<String, dynamic> json) =>
    TargetAudience(
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      organizationLevels: (json['organization_levels'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      specificUsers: (json['specific_users'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$TargetAudienceToJson(TargetAudience instance) =>
    <String, dynamic>{
      'roles': instance.roles,
      'organization_levels': instance.organizationLevels,
      'specific_users': instance.specificUsers,
    };

ReadReceipt _$ReadReceiptFromJson(Map<String, dynamic> json) => ReadReceipt(
  userId: (json['user_id'] as num).toInt(),
  readAt: DateTime.parse(json['read_at'] as String),
);

Map<String, dynamic> _$ReadReceiptToJson(ReadReceipt instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'read_at': instance.readAt.toIso8601String(),
    };

CreateNotificationRequest _$CreateNotificationRequestFromJson(
  Map<String, dynamic> json,
) => CreateNotificationRequest(
  title: json['title'] as String,
  message: json['message'] as String,
  type: json['type'] as String,
  targetAudience: json['target_audience'] == null
      ? null
      : TargetAudience.fromJson(
          json['target_audience'] as Map<String, dynamic>,
        ),
  sentVia: (json['sent_via'] as List<dynamic>).map((e) => e as String).toList(),
  scheduledAt: json['scheduled_at'] == null
      ? null
      : DateTime.parse(json['scheduled_at'] as String),
);

Map<String, dynamic> _$CreateNotificationRequestToJson(
  CreateNotificationRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'message': instance.message,
  'type': instance.type,
  'target_audience': instance.targetAudience?.toJson(),
  'sent_via': instance.sentVia,
  'scheduled_at': instance.scheduledAt?.toIso8601String(),
};
