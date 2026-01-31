import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../routes/app_router.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStatsProvider);
    final memberState = ref.watch(memberStatsProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(dashboardStatsProvider.notifier).refresh();
          await ref.read(memberStatsProvider.notifier).loadStats();
        },
        child: _buildBody(dashboardState, memberState, user, theme),
      ),
    );
  }

  Widget _buildBody(
    DashboardStatsState dashboardState,
    MemberStatsState memberState,
    dynamic user,
    ThemeData theme,
  ) {
    if (dashboardState.isLoading && dashboardState.stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dashboardState.error != null && dashboardState.stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Error loading dashboard', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              dashboardState.error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.read(dashboardStatsProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final stats = dashboardState.stats;
    if (stats == null) {
      return const Center(child: Text('No dashboard data available'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome Card
        _buildWelcomeCard(user, theme),
        const SizedBox(height: 16),

        // Key Metrics Grid
        _buildKeyMetrics(stats, theme),
        const SizedBox(height: 16),

        // Activity Status Section
        _buildActivityStatusSection(stats, theme),
        const SizedBox(height: 16),

        // Member Statistics
        if (memberState.stats != null) ...[
          _buildMemberStatsSection(memberState.stats!, theme),
          const SizedBox(height: 16),
        ],

        // Activity Breakdown by Type
        if (stats.activitiesByType != null &&
            stats.activitiesByType!.isNotEmpty) ...[
          _buildActivityTypesSection(stats, theme),
          const SizedBox(height: 16),
        ],

        // Recent Trends
        if (stats.activityTrends != null && stats.activityTrends!.isNotEmpty)
          _buildTrendsSection(stats, theme),
      ],
    );
  }

  Widget _buildWelcomeCard(dynamic user, ThemeData theme) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.fullName ?? 'User',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(now),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.dashboard,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(dynamic stats, ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          title: 'Total Members',
          value: '${stats.totalMembers}',
          icon: Icons.people,
          color: Colors.blue,
          theme: theme,
        ),
        _buildMetricCard(
          title: 'Total Activities',
          value: '${stats.totalActivities}',
          icon: Icons.assignment,
          color: Colors.green,
          theme: theme,
        ),
        _buildMetricCard(
          title: 'Pending Activities',
          value: '${stats.pendingActivities}',
          icon: Icons.pending_actions,
          color: Colors.orange,
          theme: theme,
        ),
        _buildMetricCard(
          title: 'Verified Activities',
          value: '${stats.verifiedActivities}',
          icon: Icons.verified,
          color: Colors.teal,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStatusSection(dynamic stats, ThemeData theme) {
    final total = stats.totalActivities;
    final verified = stats.verifiedActivities;
    final pending = stats.pendingActivities;
    final rejected = stats.rejectedActivities;
    final user = ref.watch(currentUserProvider);
    final isAdminOrIncharge = user?.role == 'admin' || user?.role == 'Incharge';

    return Card(
      child: InkWell(
        onTap: isAdminOrIncharge
            ? () => context.push(AppRoutes.activities)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Activity Status Overview',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isAdminOrIncharge)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
              if (isAdminOrIncharge) ...[
                const SizedBox(height: 4),
                Text(
                  'Tap to view and manage activities',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildStatusRow(
                label: 'Verified',
                count: verified,
                total: total,
                color: Colors.green,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildStatusRow(
                label: 'Pending',
                count: pending,
                total: total,
                color: Colors.orange,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildStatusRow(
                label: 'Rejected',
                count: rejected,
                total: total,
                color: Colors.red,
                theme: theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required String label,
    required int count,
    required int total,
    required Color color,
    required ThemeData theme,
  }) {
    final percentage = total > 0
        ? (count / total * 100).toStringAsFixed(1)
        : '0.0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyLarge),
            Text(
              '$count ($percentage%)',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: total > 0 ? count / total : 0,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildMemberStatsSection(dynamic memberStats, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Member Statistics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMemberStatItem(
                    'Active',
                    memberStats.activeMembers,
                    Colors.green,
                    theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMemberStatItem(
                    'Inactive',
                    memberStats.inactiveMembers,
                    Colors.grey,
                    theme,
                  ),
                ),
              ],
            ),
            if (memberStats.topPerformers != null &&
                memberStats.topPerformers.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Top Performers',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...memberStats.topPerformers
                  .take(5)
                  .map<Widget>(
                    (performer) => _buildTopPerformerItem(performer, theme),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMemberStatItem(
    String label,
    int count,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildTopPerformerItem(dynamic performer, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              performer.userName[0].toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  performer.userName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${performer.activityCount} activities',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (performer.performanceScore != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${performer.performanceScore!.toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityTypesSection(dynamic stats, ThemeData theme) {
    final activitiesByType = stats.activitiesByType as Map<String, dynamic>;
    final entries = activitiesByType.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activities by Type',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...entries.map((entry) {
              final type = entry.key;
              final count = entry.value as int;
              final total = stats.totalActivities;
              final percentage = total > 0
                  ? (count / total * 100).toStringAsFixed(1)
                  : '0.0';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        _formatActivityType(type),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$count ($percentage%)',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: total > 0 ? count / total : 0,
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsSection(dynamic stats, ThemeData theme) {
    final trends = stats.activityTrends as List<dynamic>;
    final sortedTrends = trends.toList()
      ..sort(
        (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)),
      );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Trends (Last ${trends.length} days)',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sortedTrends.length,
                itemBuilder: (context, index) {
                  final trend = sortedTrends[index];
                  final date = DateTime.parse(trend.date);
                  final count = trend.count as int;
                  final maxCount = sortedTrends
                      .map((t) => t.count as int)
                      .reduce((a, b) => a > b ? a : b);
                  final height = maxCount > 0 ? (count / maxCount * 150) : 0.0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$count',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: height,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('MMM\ndd').format(date),
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatActivityType(String type) {
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
