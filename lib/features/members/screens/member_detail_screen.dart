import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/user_model.dart';
import '../../../core/constants/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/members_provider.dart';

class MemberDetailScreen extends ConsumerWidget {
  final int memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memberDetailProvider(memberId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Details'),
        actions: [
          if (_canEditMember(currentUser))
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Navigate to edit member screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit member feature coming soon'),
                  ),
                );
              },
            ),
        ],
      ),
      body: _buildBody(context, state, currentUser, ref),
    );
  }

  bool _canEditMember(dynamic currentUser) {
    if (currentUser == null) return false;
    final role = UserRole.fromString(currentUser.role);
    return role == UserRole.admin || role == UserRole.incharge;
  }

  Widget _buildBody(
    BuildContext context,
    MemberDetailState state,
    dynamic currentUser,
    WidgetRef ref,
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
              'Error loading member',
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
                ref.read(memberDetailProvider(memberId).notifier).loadMember();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final member = state.member;
    if (member == null) {
      return const Center(child: Text('Member not found'));
    }

    final theme = Theme.of(context);
    final role = UserRole.fromString(member.role);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(memberDetailProvider(memberId).notifier).loadMember();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          _buildProfileHeader(member, role, theme),
          const SizedBox(height: 16),

          // Personal Information
          _buildPersonalInfoCard(member, theme),
          const SizedBox(height: 16),

          // Organization Details
          _buildOrganizationCard(member, theme),
          const SizedBox(height: 16),

          // Account Status
          _buildAccountStatusCard(member, theme),
          const SizedBox(height: 16),

          // Actions (Admin/Incharge only)
          if (_canEditMember(currentUser)) ...[
            _buildActionsCard(context, member, ref, theme),
            const SizedBox(height: 16),
          ],

          // Recent Activities (if available)
          _buildActivitiesCard(member, theme),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User member, UserRole role, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: _getRoleColor(role),
              child: member.profilePhoto != null
                  ? ClipOval(
                      child: Image.network(
                        member.profilePhoto!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            member.fullName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    )
                  : Text(
                      member.fullName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              member.fullName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            _buildRoleBadge(role, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(User member, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Personal Information',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.badge,
              'Username',
              member.phone ?? 'N/A',
              theme,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.email, 'Email', member.email ?? 'N/A', theme),
            if (member.phone != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone, 'Phone', member.phone!, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationCard(User member, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Organization Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (member.organizationLevel != null)
              _buildInfoRow(
                Icons.layers,
                'Level',
                member.organizationLevel!.toUpperCase(),
                theme,
              ),
            if (member.organizationPath != null &&
                member.organizationPath!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.account_tree,
                'Organization Path',
                member.organizationPath!.join(' → '),
                theme,
              ),
            ],
            if (member.postType != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.work,
                'Post Type',
                member.postType!.toUpperCase(),
                theme,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStatusCard(User member, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Account Status',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _buildStatusBadge(
                  member.isActive ? 'Active' : 'Inactive',
                  member.isActive ? Colors.green : Colors.red,
                  theme,
                ),
                const SizedBox(width: 12),
                _buildStatusBadge(
                  member.isVerified ? 'Verified' : 'Unverified',
                  member.isVerified ? Colors.blue : Colors.orange,
                  theme,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.calendar_today,
              'Joined',
              DateFormat('MMMM dd, yyyy').format(member.createdAt),
              theme,
            ),
            if (member.lastLogin != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.access_time,
                'Last Login',
                DateFormat('MMMM dd, yyyy - hh:mm a').format(member.lastLogin!),
                theme,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(
    BuildContext context,
    User member,
    WidgetRef ref,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: member.isActive
                      ? null
                      : () => _activateMember(context, member, ref),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Activate'),
                ),
                OutlinedButton.icon(
                  onPressed: member.isActive
                      ? () => _deactivateMember(context, member, ref)
                      : null,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Deactivate'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reset password feature coming soon'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.lock_reset),
                  label: const Text('Reset Password'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesCard(User member, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activities',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to member activities
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const Divider(height: 24),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Activity history coming soon'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(UserRole role, ThemeData theme) {
    final color = _getRoleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        role.displayName.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.purple;
      case UserRole.incharge:
        return Colors.blue;
      case UserRole.activist:
        return Colors.green;
      case UserRole.volunteer:
        return Colors.orange;
    }
  }

  Future<void> _activateMember(
    BuildContext context,
    User member,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate Member'),
        content: Text('Are you sure you want to activate ${member.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Activate'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // TODO: Call API to activate member
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activate member feature coming soon')),
      );
    }
  }

  Future<void> _deactivateMember(
    BuildContext context,
    User member,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Member'),
        content: Text(
          'Are you sure you want to deactivate ${member.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // TODO: Call API to deactivate member
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deactivate member feature coming soon')),
      );
    }
  }
}
