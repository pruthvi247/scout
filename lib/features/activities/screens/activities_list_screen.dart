import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/enums.dart';
import '../../../models/activity_model.dart';
import '../providers/activity_provider.dart';
import '../../../routes/app_router.dart';

class ActivitiesListScreen extends ConsumerStatefulWidget {
  final bool showOnlyMyActivities;

  const ActivitiesListScreen({super.key, this.showOnlyMyActivities = false});

  @override
  ConsumerState<ActivitiesListScreen> createState() =>
      _ActivitiesListScreenState();
}

class _ActivitiesListScreenState extends ConsumerState<ActivitiesListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final provider = widget.showOnlyMyActivities
          ? myActivitiesProvider
          : allActivitiesProvider;
      ref.read(provider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.showOnlyMyActivities
        ? myActivitiesProvider
        : allActivitiesProvider;
    final state = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.showOnlyMyActivities ? 'My Activities' : 'All Activities',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(provider.notifier).refresh();
        },
        child: _buildBody(state),
      ),
      floatingActionButton: widget.showOnlyMyActivities
          ? FloatingActionButton.extended(
              onPressed: () {
                context.push(AppRoutes.createActivity);
              },
              icon: const Icon(Icons.add),
              label: const Text('New Activity'),
            )
          : null,
    );
  }

  Widget _buildBody(ActivityListState state) {
    if (state.isLoading && state.activities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading activities',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                final provider = widget.showOnlyMyActivities
                    ? myActivitiesProvider
                    : allActivitiesProvider;
                ref.read(provider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No activities yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.showOnlyMyActivities
                  ? 'Create your first activity to get started'
                  : 'No activities to display',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.activities.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.activities.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final activity = state.activities[index];
        return ActivityCard(
          activity: activity,
          onTap: () {
            context.push('${AppRoutes.activities}/${activity.id}');
          },
        );
      },
    );
  }

  void _showFilterDialog() {
    // TODO: Implement filter dialog in next iteration
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Activities'),
        content: const Text('Filter options coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;

  const ActivityCard({super.key, required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = ActivityStatus.fromString(activity.status);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      activity.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(status, theme),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                activity.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    icon: Icons.event,
                    label: DateFormat(
                      'MMM dd, yyyy',
                    ).format(activity.checkInTime),
                    theme: theme,
                  ),
                  _buildInfoChip(
                    icon: Icons.access_time,
                    label: DateFormat('hh:mm a').format(activity.checkInTime),
                    theme: theme,
                  ),
                  _buildInfoChip(
                    icon: Icons.location_on,
                    label: activity.location.address,
                    theme: theme,
                  ),
                ],
              ),
              if (activity.tags != null && activity.tags!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: activity.tags!
                      .take(3)
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
              if (activity.mediaFiles != null &&
                  activity.mediaFiles!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${activity.mediaFiles!.length} photo(s)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ActivityStatus status, ThemeData theme) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case ActivityStatus.verified:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        break;
      case ActivityStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        break;
      case ActivityStatus.rejected:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
