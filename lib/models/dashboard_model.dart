import 'package:json_annotation/json_annotation.dart';

part 'dashboard_model.g.dart';

@JsonSerializable()
class DashboardStats {
  final int totalMembers;
  final int totalActivities;
  final int pendingActivities;
  final int verifiedActivities;
  final int rejectedActivities;
  final int organizationNodes;
  final int activeVolunteers;
  final int pendingFeedback;
  final Map<String, int>? activitiesByType;
  final Map<String, int>? membersByRole;
  final Map<String, int>? activitiesByStatus;
  final List<ActivityTrend>? activityTrends;

  DashboardStats({
    required this.totalMembers,
    required this.totalActivities,
    required this.pendingActivities,
    required this.verifiedActivities,
    required this.rejectedActivities,
    required this.organizationNodes,
    required this.activeVolunteers,
    required this.pendingFeedback,
    this.activitiesByType,
    this.membersByRole,
    this.activitiesByStatus,
    this.activityTrends,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardStatsToJson(this);
}

@JsonSerializable()
class ActivityTrend {
  final String date;
  final int count;
  final String? type;

  ActivityTrend({required this.date, required this.count, this.type});

  factory ActivityTrend.fromJson(Map<String, dynamic> json) =>
      _$ActivityTrendFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityTrendToJson(this);
}

@JsonSerializable()
class MemberStats {
  final int totalMembers;
  final int activeMembers;
  final int inactiveMembers;
  final Map<String, int> membersByRole;
  final Map<String, int> membersByLevel;
  final List<TopPerformer>? topPerformers;

  MemberStats({
    required this.totalMembers,
    required this.activeMembers,
    required this.inactiveMembers,
    required this.membersByRole,
    required this.membersByLevel,
    this.topPerformers,
  });

  factory MemberStats.fromJson(Map<String, dynamic> json) =>
      _$MemberStatsFromJson(json);

  Map<String, dynamic> toJson() => _$MemberStatsToJson(this);
}

@JsonSerializable()
class TopPerformer {
  final int userId;
  final String userName;
  final int activityCount;
  final double? performanceScore;

  TopPerformer({
    required this.userId,
    required this.userName,
    required this.activityCount,
    this.performanceScore,
  });

  factory TopPerformer.fromJson(Map<String, dynamic> json) =>
      _$TopPerformerFromJson(json);

  Map<String, dynamic> toJson() => _$TopPerformerToJson(this);
}

@JsonSerializable()
class EngagementMetrics {
  final double averageActivitiesPerMember;
  final double activityCompletionRate;
  final int totalCheckIns;
  final Map<String, int> activitiesByRegion;
  final List<RegionEngagement>? regionEngagement;

  EngagementMetrics({
    required this.averageActivitiesPerMember,
    required this.activityCompletionRate,
    required this.totalCheckIns,
    required this.activitiesByRegion,
    this.regionEngagement,
  });

  factory EngagementMetrics.fromJson(Map<String, dynamic> json) =>
      _$EngagementMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$EngagementMetricsToJson(this);
}

@JsonSerializable()
class RegionEngagement {
  final String region;
  final int activityCount;
  final int memberCount;
  final double engagementRate;

  RegionEngagement({
    required this.region,
    required this.activityCount,
    required this.memberCount,
    required this.engagementRate,
  });

  factory RegionEngagement.fromJson(Map<String, dynamic> json) =>
      _$RegionEngagementFromJson(json);

  Map<String, dynamic> toJson() => _$RegionEngagementToJson(this);
}
