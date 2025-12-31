import 'package:json_annotation/json_annotation.dart';

part 'organization_model.g.dart';

@JsonSerializable()
class OrganizationNode {
  final int id;
  final String name;
  final String type;
  @JsonKey(name: 'parent_id')
  final int? parentId;
  final List<String> path;
  final int level;
  @JsonKey(name: 'assigned_member_id')
  final int? assignedMemberId;
  @JsonKey(name: 'member_count')
  final int memberCount;
  @JsonKey(name: 'activity_summary')
  final Map<String, dynamic>? activitySummary;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  // Client-side only - children loaded from tree
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<OrganizationNode>? children;

  OrganizationNode({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    required this.path,
    required this.level,
    this.assignedMemberId,
    required this.memberCount,
    this.activitySummary,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.children,
  });

  factory OrganizationNode.fromJson(Map<String, dynamic> json) =>
      _$OrganizationNodeFromJson(json);
  Map<String, dynamic> toJson() => _$OrganizationNodeToJson(this);

  OrganizationNode copyWith({List<OrganizationNode>? children}) {
    return OrganizationNode(
      id: id,
      name: name,
      type: type,
      parentId: parentId,
      path: path,
      level: level,
      assignedMemberId: assignedMemberId,
      memberCount: memberCount,
      activitySummary: activitySummary,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      children: children ?? this.children,
    );
  }
}

@JsonSerializable()
class OrganizationTree {
  final OrganizationNode root;
  @JsonKey(name: 'total_nodes')
  final int totalNodes;

  OrganizationTree({required this.root, required this.totalNodes});

  factory OrganizationTree.fromJson(Map<String, dynamic> json) =>
      _$OrganizationTreeFromJson(json);
  Map<String, dynamic> toJson() => _$OrganizationTreeToJson(this);
}
