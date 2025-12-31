// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationNode _$OrganizationNodeFromJson(Map<String, dynamic> json) =>
    OrganizationNode(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      type: json['type'] as String,
      parentId: (json['parent_id'] as num?)?.toInt(),
      path: (json['path'] as List<dynamic>).map((e) => e as String).toList(),
      level: (json['level'] as num).toInt(),
      assignedMemberId: (json['assigned_member_id'] as num?)?.toInt(),
      memberCount: (json['member_count'] as num).toInt(),
      activitySummary: json['activity_summary'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$OrganizationNodeToJson(OrganizationNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'parent_id': instance.parentId,
      'path': instance.path,
      'level': instance.level,
      'assigned_member_id': instance.assignedMemberId,
      'member_count': instance.memberCount,
      'activity_summary': instance.activitySummary,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

OrganizationTree _$OrganizationTreeFromJson(Map<String, dynamic> json) =>
    OrganizationTree(
      root: OrganizationNode.fromJson(json['root'] as Map<String, dynamic>),
      totalNodes: (json['total_nodes'] as num).toInt(),
    );

Map<String, dynamic> _$OrganizationTreeToJson(OrganizationTree instance) =>
    <String, dynamic>{
      'root': instance.root.toJson(),
      'total_nodes': instance.totalNodes,
    };
