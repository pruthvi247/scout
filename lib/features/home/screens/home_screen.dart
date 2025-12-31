import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../activities/screens/activities_list_screen.dart';
import '../../organization/screens/organization_screen.dart';
import '../../members/screens/members_list_screen.dart';
import '../../volunteers/screens/volunteer_assignments_screen.dart';
import '../../volunteers/screens/events_list_screen.dart';
import '../../activities/providers/activity_provider.dart';
import '../../organization/providers/organization_provider.dart';
import '../../members/providers/members_provider.dart';
import '../../notifications/providers/notification_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userRole = UserRole.fromString(user.role);
    final navigationItems = _getNavigationItemsForRole(userRole);

    return Scaffold(
      appBar: AppBar(
        title: Text(navigationItems[_selectedIndex].label),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              if (unreadCount.count > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount.count > 9 ? '9+' : '${unreadCount.count}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(context, user, userRole),
      body: _buildBody(userRole),
      bottomNavigationBar: navigationItems.length > 1
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: navigationItems
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            )
          : null,
    );
  }

  Widget _buildDrawer(BuildContext context, dynamic user, UserRole role) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                user.fullName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 40,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            accountName: Text(
              user.fullName,
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              user.email,
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(AppStrings.profile),
            onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.admin_panel_settings,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              'Role: ${role.displayName}',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            enabled: false,
          ),
          if (user.organizationLevel != null)
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text('Level: ${user.organizationLevel}'),
              enabled: false,
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              AppStrings.logout,
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return _buildAdminHome();
      case UserRole.incharge:
        return _buildInchargeHome();
      case UserRole.activist:
        return _buildActivistHome();
      case UserRole.volunteer:
        return _buildVolunteerHome();
    }
  }

  Widget _buildAdminHome() {
    return _selectedIndex == 0
        ? _AdminDashboardTab()
        : _selectedIndex == 1
        ? _ActivitiesTab()
        : _selectedIndex == 2
        ? _OrganizationTab()
        : _MembersTab();
  }

  Widget _buildInchargeHome() {
    return _selectedIndex == 0
        ? _InchargeDashboardTab()
        : _selectedIndex == 1
        ? _ActivitiesTab()
        : _OrganizationTab();
  }

  Widget _buildActivistHome() {
    return _selectedIndex == 0 ? _ActivitiesTab() : _MyActivitiesTab();
  }

  Widget _buildVolunteerHome() {
    return _selectedIndex == 0
        ? _VolunteerAssignmentsTab()
        : _VolunteerEventsTab();
  }

  List<_NavigationItem> _getNavigationItemsForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [
          _NavigationItem(
            label: AppStrings.dashboard,
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
          ),
          _NavigationItem(
            label: AppStrings.activities,
            icon: Icons.event_note_outlined,
            selectedIcon: Icons.event_note,
          ),
          _NavigationItem(
            label: AppStrings.organization,
            icon: Icons.account_tree_outlined,
            selectedIcon: Icons.account_tree,
          ),
          _NavigationItem(
            label: AppStrings.members,
            icon: Icons.people_outline,
            selectedIcon: Icons.people,
          ),
        ];
      case UserRole.incharge:
        return [
          _NavigationItem(
            label: AppStrings.dashboard,
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
          ),
          _NavigationItem(
            label: AppStrings.activities,
            icon: Icons.event_note_outlined,
            selectedIcon: Icons.event_note,
          ),
          _NavigationItem(
            label: AppStrings.organization,
            icon: Icons.account_tree_outlined,
            selectedIcon: Icons.account_tree,
          ),
        ];
      case UserRole.activist:
        return [
          _NavigationItem(
            label: AppStrings.activities,
            icon: Icons.event_note_outlined,
            selectedIcon: Icons.event_note,
          ),
          _NavigationItem(
            label: AppStrings.myActivities,
            icon: Icons.assignment_outlined,
            selectedIcon: Icons.assignment,
          ),
        ];
      case UserRole.volunteer:
        return [
          _NavigationItem(
            label: 'Assignments',
            icon: Icons.assignment_outlined,
            selectedIcon: Icons.assignment,
          ),
          _NavigationItem(
            label: AppStrings.events,
            icon: Icons.event_outlined,
            selectedIcon: Icons.event,
          ),
        ];
    }
  }
}

class _NavigationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

// Dashboard tabs with real data
class _AdminDashboardTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allActivitiesState = ref.watch(allActivitiesProvider);
    final pendingActivitiesState = ref.watch(pendingActivitiesProvider);
    final orgTreeState = ref.watch(organizationTreeProvider);
    final membersState = ref.watch(allMembersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(allActivitiesProvider.notifier).refresh(),
          ref.read(pendingActivitiesProvider.notifier).refresh(),
          ref.read(organizationTreeProvider.notifier).refresh(),
          ref.read(allMembersProvider.notifier).refresh(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Activities',
                  value: allActivitiesState.activities.length.toString(),
                  icon: Icons.event_note,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Pending',
                  value: pendingActivitiesState.activities.length.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Members',
                  value: membersState.members.length.toString(),
                  icon: Icons.people,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Nodes',
                  value: (orgTreeState.tree?.totalNodes ?? 0).toString(),
                  icon: Icons.account_tree,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Activities
          if (allActivitiesState.activities.isNotEmpty) ...[
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...allActivitiesState.activities.take(5).map((activity) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.event,
                    color: _getActivityStatusColor(activity.status),
                  ),
                  title: Text(activity.title),
                  subtitle: Text(activity.activityType),
                  trailing: _buildStatusChip(activity.status),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Color _getActivityStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip(String status) {
    final color = _getActivityStatusColor(status);
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withOpacity(0.1),
    );
  }
}

class _InchargeDashboardTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myActivitiesState = ref.watch(myActivitiesProvider);
    final pendingActivitiesState = ref.watch(pendingActivitiesProvider);
    final orgTreeState = ref.watch(organizationTreeProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.read(myActivitiesProvider.notifier).refresh(),
          ref.read(pendingActivitiesProvider.notifier).refresh(),
          ref.read(organizationTreeProvider.notifier).refresh(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'My Activities',
                  value: myActivitiesState.activities.length.toString(),
                  icon: Icons.assignment,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Pending Review',
                  value: pendingActivitiesState.activities.length.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Organization Overview
          if (orgTreeState.tree != null) ...[
            Text(
              'Organization Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_tree),
                        const SizedBox(width: 12),
                        Text(
                          orgTreeState.tree!.root.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Total Nodes: ${orgTreeState.tree!.totalNodes}'),
                    Text('Members: ${orgTreeState.tree!.root.memberCount}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ActivitiesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ActivitiesListScreen();
  }
}

class _MyActivitiesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ActivitiesListScreen(showOnlyMyActivities: true);
  }
}

class _OrganizationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const OrganizationScreen();
  }
}

class _MembersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MembersListScreen();
  }
}

class _VolunteerAssignmentsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Assuming we have the volunteer ID from the user
    return VolunteerAssignmentsScreen(volunteerId: user.id);
  }
}

class _VolunteerEventsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const EventsListScreen();
  }
}
