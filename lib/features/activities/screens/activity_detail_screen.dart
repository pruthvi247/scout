import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/enums.dart';
import '../../../models/activity_model.dart';
import '../providers/activity_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ActivityDetailScreen extends ConsumerWidget {
  final int activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityDetailProvider(activityId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Details'),
        actions: [
          if (state.activity != null && currentUser != null) ...[
            if (_canModifyActivity(state.activity!, currentUser))
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleMenuAction(value, context, ref, state.activity!),
                itemBuilder: (context) => [
                  if (state.activity!.status == 'pending' &&
                      _canVerifyActivity(currentUser)) ...[
                    const PopupMenuItem(
                      value: 'verify',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Verify'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'reject',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Reject'),
                        ],
                      ),
                    ),
                  ],
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
      body: _buildBody(context, ref, state, currentUser),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ActivityDetailState state,
    dynamic currentUser,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
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
              'Error loading activity',
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
                ref
                    .read(activityDetailProvider(activityId).notifier)
                    .loadActivity();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.activity == null) {
      return const Center(child: Text('Activity not found'));
    }

    final activity = state.activity!;
    final status = ActivityStatus.fromString(activity.status);

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(activityDetailProvider(activityId).notifier)
            .loadActivity();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Badge
          _buildStatusBadge(context, status),
          const SizedBox(height: 16),

          // Title & Description Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getActivityTypeIcon(activity.activityType),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatActivityType(activity.activityType),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activity.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activity.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Date & Time Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date & Time',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      DateFormat(
                        'EEEE, MMMM dd, yyyy',
                      ).format(activity.checkInTime),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      DateFormat('hh:mm a').format(activity.checkInTime),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Location Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(activity.location.address),
                    subtitle: Text(
                      'Lat: ${activity.location.lat.toStringAsFixed(6)}, '
                      'Lng: ${activity.location.lng.toStringAsFixed(6)}',
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Organization Level
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.business),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Organization Level',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.organizationLevel.toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tags
          if (activity.tags != null && activity.tags!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: activity.tags!
                          .map((tag) => Chip(label: Text(tag)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Media Files
          if (activity.mediaFiles != null &&
              activity.mediaFiles!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: activity.mediaFiles!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.photo),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Verification Info
          if (activity.verifiedBy != null && activity.verifiedAt != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Verified',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.green.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verified on ${DateFormat('MMM dd, yyyy at hh:mm a').format(activity.verifiedAt!)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Metadata
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildMetadataRow(
                    context,
                    'Created',
                    DateFormat(
                      'MMM dd, yyyy at hh:mm a',
                    ).format(activity.createdAt),
                  ),
                  _buildMetadataRow(
                    context,
                    'Last Updated',
                    DateFormat(
                      'MMM dd, yyyy at hh:mm a',
                    ).format(activity.updatedAt),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ActivityStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case ActivityStatus.verified:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.check_circle;
        break;
      case ActivityStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        icon = Icons.pending;
        break;
      case ActivityStatus.rejected:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 8),
          Text(
            status.displayName.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  IconData _getActivityTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'meeting':
        return Icons.people;
      case 'social_event':
        return Icons.celebration;
      case 'campaign':
        return Icons.campaign;
      case 'door_to_door':
        return Icons.house;
      case 'rally':
        return Icons.flag;
      case 'training':
        return Icons.school;
      default:
        return Icons.event;
    }
  }

  String _formatActivityType(String type) {
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  bool _canModifyActivity(Activity activity, dynamic currentUser) {
    if (currentUser == null) return false;

    final userRole = UserRole.fromString(currentUser.role);

    // Admins can modify anything
    if (userRole == UserRole.admin) return true;

    // Incharges can modify activities in their organization
    if (userRole == UserRole.incharge) return true;

    // Users can modify their own activities
    return activity.userId == currentUser.id;
  }

  bool _canVerifyActivity(dynamic currentUser) {
    if (currentUser == null) return false;

    final userRole = UserRole.fromString(currentUser.role);
    return userRole == UserRole.admin || userRole == UserRole.incharge;
  }

  void _handleMenuAction(
    String action,
    BuildContext context,
    WidgetRef ref,
    Activity activity,
  ) {
    switch (action) {
      case 'verify':
        _verifyActivity(context, ref);
        break;
      case 'reject':
        _showRejectDialog(context, ref);
        break;
      case 'delete':
        _showDeleteDialog(context, ref);
        break;
    }
  }

  Future<void> _verifyActivity(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Activity'),
        content: const Text('Are you sure you want to verify this activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(activityDetailProvider(activityId).notifier)
          .verifyActivity();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity verified successfully')),
        );
      }
    }
  }

  Future<void> _showRejectDialog(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Activity'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(activityDetailProvider(activityId).notifier)
          .rejectActivity(reasonController.text);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Activity rejected')));
      }
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text(
          'Are you sure you want to delete this activity? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(activityDetailProvider(activityId).notifier)
          .deleteActivity();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Activity deleted')));
      }
    }
  }
}
