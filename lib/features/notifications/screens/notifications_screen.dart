import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../../../models/notification_model.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _typeFilter;
  String? _statusFilter;

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
      ref.read(notificationsListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsListProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications'),
            if (unreadCount.count > 0)
              Text(
                '${unreadCount.count} unread',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
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
          await ref.read(notificationsListProvider.notifier).refresh();
          await ref.read(unreadCountProvider.notifier).loadUnreadCount();
        },
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(NotificationsListState state) {
    // TODO: Backend notification API not implemented yet
    // Show coming soon message
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Notifications Coming Soon',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Backend API not yet implemented',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );

    /* Original implementation - restore when backend is ready
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.notifications.isEmpty) {
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
              'Error loading notifications',
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
                ref.read(notificationsListProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text('No notifications yet'),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.notifications.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final notification = state.notifications[index];
        return NotificationCard(
          notification: notification,
          onTap: () => _onNotificationTap(notification),
        );
      },
    );
    */
  }

  void _onNotificationTap(NotificationModel notification) {
    if (notification.isRead != true) {
      ref.read(notificationsListProvider.notifier).markAsRead(notification.id);
      ref.read(unreadCountProvider.notifier).decrementCount();
    }

    // Show notification detail dialog
    showDialog(
      context: context,
      builder: (context) =>
          NotificationDetailDialog(notification: notification),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _typeFilter,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'info', child: Text('Info')),
                DropdownMenuItem(value: 'alert', child: Text('Alert')),
                DropdownMenuItem(value: 'reminder', child: Text('Reminder')),
                DropdownMenuItem(
                  value: 'announcement',
                  child: Text('Announcement'),
                ),
              ],
              onChanged: (value) {
                setState(() => _typeFilter = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _statusFilter,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'sent', child: Text('Sent')),
                DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                DropdownMenuItem(value: 'draft', child: Text('Draft')),
              ],
              onChanged: (value) {
                setState(() => _statusFilter = value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(notificationsListProvider.notifier)
                  .loadNotifications(type: _typeFilter, status: _statusFilter);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = notification.isRead != true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isUnread
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(notification.type),
          child: Icon(_getTypeIcon(notification.type), color: Colors.white),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(notification.createdAt),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: _buildTypeChip(notification.type, theme),
        onTap: onTap,
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'info':
        return Colors.blue;
      case 'alert':
        return Colors.red;
      case 'reminder':
        return Colors.orange;
      case 'announcement':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'info':
        return Icons.info;
      case 'alert':
        return Icons.warning;
      case 'reminder':
        return Icons.alarm;
      case 'announcement':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildTypeChip(String type, ThemeData theme) {
    return Chip(
      label: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getTypeColor(type),
        ),
      ),
      visualDensity: VisualDensity.compact,
      backgroundColor: _getTypeColor(type).withOpacity(0.1),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return DateFormat('MMM d, y').format(date);
  }
}

class NotificationDetailDialog extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailDialog({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getTypeIcon(notification.type),
            color: _getTypeColor(notification.type),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(notification.title)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(notification.message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Type', notification.type.toUpperCase()),
            _buildInfoRow('Status', notification.status.toUpperCase()),
            if (notification.sentAt != null)
              _buildInfoRow(
                'Sent',
                DateFormat('MMM d, y - h:mm a').format(notification.sentAt!),
              ),
            _buildInfoRow(
              'Created',
              DateFormat('MMM d, y - h:mm a').format(notification.createdAt),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'info':
        return Colors.blue;
      case 'alert':
        return Colors.red;
      case 'reminder':
        return Colors.orange;
      case 'announcement':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'info':
        return Icons.info;
      case 'alert':
        return Icons.warning;
      case 'reminder':
        return Icons.alarm;
      case 'announcement':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }
}
