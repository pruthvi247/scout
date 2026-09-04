import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/enums.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.profile)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final userRole = UserRole.fromString(user.role);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile - Coming soon')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: user.profilePhoto != null
                      ? null
                      : Text(
                          user.fullName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 48,
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.fullName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(userRole.displayName),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  avatar: Icon(
                    Icons.admin_panel_settings,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Personal Information
          _SectionHeader(title: 'Personal Information'),
          const SizedBox(height: 8),
          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.person_outline,
                label: 'Username',
                value: user.phone ?? 'N/A',
              ),
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
              ),
              if (user.phone != null)
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: user.phone!,
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Organization Details
          _SectionHeader(title: 'Organization Details'),
          const SizedBox(height: 8),
          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.badge_outlined,
                label: 'Role',
                value: userRole.displayName,
              ),
              if (user.postType != null)
                _InfoRow(
                  icon: Icons.work_outline,
                  label: 'Post Type',
                  value: PostType.fromString(user.postType!).displayName,
                ),
              if (user.organizationLevel != null)
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Organization Level',
                  value: user.organizationLevel!,
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Account Status
          _SectionHeader(title: 'Account Status'),
          const SizedBox(height: 8),
          _InfoCard(
            children: [
              _InfoRow(
                icon: user.isActive
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                label: 'Account Status',
                value: user.isActive ? 'Active' : 'Inactive',
                valueColor: user.isActive ? Colors.green : Colors.red,
              ),
              _InfoRow(
                icon: user.isVerified
                    ? Icons.verified_outlined
                    : Icons.pending_outlined,
                label: 'Verification',
                value: user.isVerified ? 'Verified' : 'Pending',
                valueColor: user.isVerified ? Colors.green : Colors.orange,
              ),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Member Since',
                value: DateFormat('MMM dd, yyyy').format(user.createdAt),
              ),
              if (user.lastLogin != null)
                _InfoRow(
                  icon: Icons.login_outlined,
                  label: 'Last Login',
                  value: DateFormat(
                    'MMM dd, yyyy HH:mm',
                  ).format(user.lastLogin!),
                ),
            ],
          ),
          const SizedBox(height: 32),

          // Logout Button
          FilledButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await ref.read(authProvider.notifier).logout();
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text(AppStrings.logout),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
