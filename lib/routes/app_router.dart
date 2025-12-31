import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/activities/screens/activities_list_screen.dart';
import '../features/activities/screens/create_activity_screen.dart';
import '../features/activities/screens/activity_detail_screen.dart';
import '../features/organization/screens/organization_screen.dart';
import '../features/members/screens/members_list_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/volunteers/screens/events_list_screen.dart';
import '../features/auth/providers/auth_provider.dart';

// Route paths
class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String activities = '/activities';
  static const String createActivity = '/activities/create';
  static const String activityDetail = '/activities/:id';
  static const String organization = '/organization';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String members = '/members';
  static const String volunteers = '/volunteers';
  static const String events = '/events';
  static const String feedback = '/feedback';
  static const String content = '/content';
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;

      // Wait for auth check to complete
      if (isLoading) {
        return null;
      }

      // Redirect to login if not authenticated
      if (!isAuthenticated && !isLoginRoute) {
        return AppRoutes.login;
      }

      // Redirect to home if authenticated and trying to access login
      if (isAuthenticated && isLoginRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Dashboard'),
      ),
      GoRoute(
        path: AppRoutes.activities,
        builder: (context, state) => const ActivitiesListScreen(),
      ),
      GoRoute(
        path: AppRoutes.createActivity,
        builder: (context, state) => const CreateActivityScreen(),
      ),
      GoRoute(
        path: '/activities/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ActivityDetailScreen(activityId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.organization,
        builder: (context, state) => const OrganizationScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.members,
        builder: (context, state) => const MembersListScreen(),
      ),
      GoRoute(
        path: AppRoutes.volunteers,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Volunteers'),
      ),
      GoRoute(
        path: AppRoutes.events,
        builder: (context, state) => const EventsListScreen(),
      ),
    ],
  );
});

// Placeholder screen for routes not yet implemented
class PlaceholderScreen extends ConsumerWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '$title Screen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
