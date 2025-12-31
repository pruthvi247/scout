import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/user_api_service.dart';
import '../../../core/providers/network_providers.dart';
import '../../../models/user_model.dart';
import '../../../models/activity_model.dart';

/// Provider for UserApiService
final userApiServiceProvider = Provider<UserApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return UserApiService(dio);
});

/// State for members list
class MembersListState {
  final List<User> members;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  MembersListState({
    this.members = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  MembersListState copyWith({
    List<User>? members,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return MembersListState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Members list notifier
class MembersListNotifier extends StateNotifier<MembersListState> {
  final UserApiService _userApiService;
  final String? roleFilter;
  final String? organizationLevelFilter;

  MembersListNotifier(
    this._userApiService, {
    this.roleFilter,
    this.organizationLevelFilter,
  }) : super(MembersListState()) {
    loadMembers();
  }

  Future<void> loadMembers({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = MembersListState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final members = await _userApiService.getUsers(
        role: roleFilter,
        organizationLevel: organizationLevelFilter,
        page: refresh ? 1 : state.currentPage,
        limit: 20,
      );

      if (refresh) {
        state = MembersListState(
          members: members,
          isLoading: false,
          hasMore: members.length >= 20,
          currentPage: 1,
        );
      } else {
        state = state.copyWith(
          members: [...state.members, ...members],
          isLoading: false,
          hasMore: members.length >= 20,
          currentPage: state.currentPage + 1,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadMembers();
  }

  Future<void> refresh() async {
    await loadMembers(refresh: true);
  }
}

/// Provider for all members
final allMembersProvider =
    StateNotifierProvider<MembersListNotifier, MembersListState>((ref) {
      final userApiService = ref.watch(userApiServiceProvider);
      return MembersListNotifier(userApiService);
    });

/// State for user activities
class UserActivitiesState {
  final List<Activity> activities;
  final bool isLoading;
  final String? error;

  UserActivitiesState({
    this.activities = const [],
    this.isLoading = false,
    this.error,
  });

  UserActivitiesState copyWith({
    List<Activity>? activities,
    bool? isLoading,
    String? error,
  }) {
    return UserActivitiesState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// User activities notifier
class UserActivitiesNotifier extends StateNotifier<UserActivitiesState> {
  final UserApiService _userApiService;
  final int userId;

  UserActivitiesNotifier(this._userApiService, this.userId)
    : super(UserActivitiesState(isLoading: true)) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final activities = await _userApiService.getUserActivities(userId);
      state = UserActivitiesState(activities: activities, isLoading: false);
    } catch (e) {
      state = UserActivitiesState(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadActivities();
  }
}

/// Provider for user activities
final userActivitiesProvider =
    StateNotifierProvider.family<
      UserActivitiesNotifier,
      UserActivitiesState,
      int
    >((ref, userId) {
      final userApiService = ref.watch(userApiServiceProvider);
      return UserActivitiesNotifier(userApiService, userId);
    });
