import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/enums.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../activities/screens/activities_list_screen.dart';
import '../../organization/screens/organization_screen.dart';
import '../../members/screens/members_list_screen.dart';
import '../../volunteers/screens/volunteer_assignments_screen.dart';
import '../../volunteers/screens/events_list_screen.dart';
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
        ? const DashboardScreen()
        : _selectedIndex == 1
        ? const ActivitiesListScreen(showOnlyMyActivities: true)
        : _selectedIndex == 2
        ? const OrganizationScreen()
        : const MembersListScreen();
  }

  Widget _buildInchargeHome() {
    return _selectedIndex == 0
        ? const DashboardScreen()
        : _selectedIndex == 1
        ? const ActivitiesListScreen(showOnlyMyActivities: true)
        : const OrganizationScreen();
  }

  Widget _buildActivistHome() {
    return const ActivitiesListScreen(showOnlyMyActivities: true);
  }

  Widget _buildVolunteerHome() {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return _selectedIndex == 0
        ? VolunteerAssignmentsScreen(volunteerId: user.id)
        : const EventsListScreen();
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
