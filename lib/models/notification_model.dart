import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type; // info, alert, reminder, announcement
  final TargetAudience? targetAudience;
  final List<String> sentVia; // app_push, sms, email
  final String status; // draft, scheduled, sent
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final int createdBy;
  final List<ReadReceipt>? readBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool? isRead; // Client-side only

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.targetAudience,
    required this.sentVia,
    required this.status,
    this.scheduledAt,
    this.sentAt,
    required this.createdBy,
    this.readBy,
    required this.createdAt,
    required this.updatedAt,
    this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      targetAudience: targetAudience,
      sentVia: sentVia,
      status: status,
      scheduledAt: scheduledAt,
      sentAt: sentAt,
      createdBy: createdBy,
      readBy: readBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

@JsonSerializable()
class TargetAudience {
  final List<String>? roles;
  final List<String>? organizationLevels;
  final List<int>? specificUsers;

  TargetAudience({this.roles, this.organizationLevels, this.specificUsers});

  factory TargetAudience.fromJson(Map<String, dynamic> json) =>
      _$TargetAudienceFromJson(json);

  Map<String, dynamic> toJson() => _$TargetAudienceToJson(this);
}

@JsonSerializable()
class ReadReceipt {
  final int userId;
  final DateTime readAt;

  ReadReceipt({required this.userId, required this.readAt});

  factory ReadReceipt.fromJson(Map<String, dynamic> json) =>
      _$ReadReceiptFromJson(json);

  Map<String, dynamic> toJson() => _$ReadReceiptToJson(this);
}

@JsonSerializable()
class CreateNotificationRequest {
  final String title;
  final String message;
  final String type;
  final TargetAudience? targetAudience;
  final List<String> sentVia;
  final DateTime? scheduledAt;

  CreateNotificationRequest({
    required this.title,
    required this.message,
    required this.type,
    this.targetAudience,
    required this.sentVia,
    this.scheduledAt,
  });

  factory CreateNotificationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateNotificationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateNotificationRequestToJson(this);
}
