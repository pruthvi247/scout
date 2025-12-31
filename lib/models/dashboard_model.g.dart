// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    DashboardStats(
      totalMembers: (json['total_members'] as num).toInt(),
      totalActivities: (json['total_activities'] as num).toInt(),
      pendingActivities: (json['pending_activities'] as num).toInt(),
      verifiedActivities: (json['verified_activities'] as num).toInt(),
      rejectedActivities: (json['rejected_activities'] as num).toInt(),
      organizationNodes: (json['organization_nodes'] as num).toInt(),
      activeVolunteers: (json['active_volunteers'] as num).toInt(),
      pendingFeedback: (json['pending_feedback'] as num).toInt(),
      activitiesByType: (json['activities_by_type'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, (e as num).toInt())),
      membersByRole: (json['members_by_role'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      activitiesByStatus:
          (json['activities_by_status'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ),
      activityTrends: (json['activity_trends'] as List<dynamic>?)
          ?.map((e) => ActivityTrend.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardStatsToJson(
  DashboardStats instance,
) => <String, dynamic>{
  'total_members': instance.totalMembers,
  'total_activities': instance.totalActivities,
  'pending_activities': instance.pendingActivities,
  'verified_activities': instance.verifiedActivities,
  'rejected_activities': instance.rejectedActivities,
  'organization_nodes': instance.organizationNodes,
  'active_volunteers': instance.activeVolunteers,
  'pending_feedback': instance.pendingFeedback,
  'activities_by_type': instance.activitiesByType,
  'members_by_role': instance.membersByRole,
  'activities_by_status': instance.activitiesByStatus,
  'activity_trends': instance.activityTrends?.map((e) => e.toJson()).toList(),
};

ActivityTrend _$ActivityTrendFromJson(Map<String, dynamic> json) =>
    ActivityTrend(
      date: json['date'] as String,
      count: (json['count'] as num).toInt(),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$ActivityTrendToJson(ActivityTrend instance) =>
    <String, dynamic>{
      'date': instance.date,
      'count': instance.count,
      'type': instance.type,
    };

MemberStats _$MemberStatsFromJson(Map<String, dynamic> json) => MemberStats(
  totalMembers: (json['total_members'] as num).toInt(),
  activeMembers: (json['active_members'] as num).toInt(),
  inactiveMembers: (json['inactive_members'] as num).toInt(),
  membersByRole: Map<String, int>.from(json['members_by_role'] as Map),
  membersByLevel: Map<String, int>.from(json['members_by_level'] as Map),
  topPerformers: (json['top_performers'] as List<dynamic>?)
      ?.map((e) => TopPerformer.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MemberStatsToJson(MemberStats instance) =>
    <String, dynamic>{
      'total_members': instance.totalMembers,
      'active_members': instance.activeMembers,
      'inactive_members': instance.inactiveMembers,
      'members_by_role': instance.membersByRole,
      'members_by_level': instance.membersByLevel,
      'top_performers': instance.topPerformers?.map((e) => e.toJson()).toList(),
    };

TopPerformer _$TopPerformerFromJson(Map<String, dynamic> json) => TopPerformer(
  userId: (json['user_id'] as num).toInt(),
  userName: json['user_name'] as String,
  activityCount: (json['activity_count'] as num).toInt(),
  performanceScore: (json['performance_score'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TopPerformerToJson(TopPerformer instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'user_name': instance.userName,
      'activity_count': instance.activityCount,
      'performance_score': instance.performanceScore,
    };

EngagementMetrics _$EngagementMetricsFromJson(Map<String, dynamic> json) =>
    EngagementMetrics(
      averageActivitiesPerMember: (json['average_activities_per_member'] as num)
          .toDouble(),
      activityCompletionRate: (json['activity_completion_rate'] as num)
          .toDouble(),
      totalCheckIns: (json['total_check_ins'] as num).toInt(),
      activitiesByRegion: Map<String, int>.from(
        json['activities_by_region'] as Map,
      ),
      regionEngagement: (json['region_engagement'] as List<dynamic>?)
          ?.map((e) => RegionEngagement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EngagementMetricsToJson(EngagementMetrics instance) =>
    <String, dynamic>{
      'average_activities_per_member': instance.averageActivitiesPerMember,
      'activity_completion_rate': instance.activityCompletionRate,
      'total_check_ins': instance.totalCheckIns,
      'activities_by_region': instance.activitiesByRegion,
      'region_engagement': instance.regionEngagement
          ?.map((e) => e.toJson())
          .toList(),
    };

RegionEngagement _$RegionEngagementFromJson(Map<String, dynamic> json) =>
    RegionEngagement(
      region: json['region'] as String,
      activityCount: (json['activity_count'] as num).toInt(),
      memberCount: (json['member_count'] as num).toInt(),
      engagementRate: (json['engagement_rate'] as num).toDouble(),
    );

Map<String, dynamic> _$RegionEngagementToJson(RegionEngagement instance) =>
    <String, dynamic>{
      'region': instance.region,
      'activity_count': instance.activityCount,
      'member_count': instance.memberCount,
      'engagement_rate': instance.engagementRate,
    };
