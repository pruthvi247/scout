import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/activity_api_service.dart';
import '../../../core/providers/network_providers.dart';
import '../../../models/activity_model.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for ActivityApiService
final activityApiServiceProvider = Provider<ActivityApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ActivityApiService(dio);
});

/// State for activity list
class ActivityListState {
  final List<Activity> activities;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  ActivityListState({
    this.activities = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  ActivityListState copyWith({
    List<Activity>? activities,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return ActivityListState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Activity list notifier
class ActivityListNotifier extends StateNotifier<ActivityListState> {
  final ActivityApiService _activityApiService;
  final String? statusFilter;
  final String? activityTypeFilter;
  final int? userIdFilter;

  ActivityListNotifier(
    this._activityApiService, {
    this.statusFilter,
    this.activityTypeFilter,
    this.userIdFilter,
  }) : super(ActivityListState()) {
    loadActivities();
  }

  Future<void> loadActivities({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = ActivityListState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final activities = await _activityApiService.getActivities(
        status: statusFilter,
        activityType: activityTypeFilter,
        userId: userIdFilter,
        page: refresh ? 1 : state.currentPage,
        limit: 20,
      );

      if (refresh) {
        state = ActivityListState(
          activities: activities,
          isLoading: false,
          hasMore: activities.length >= 20,
          currentPage: 1,
        );
      } else {
        state = state.copyWith(
          activities: [...state.activities, ...activities],
          isLoading: false,
          hasMore: activities.length >= 20,
          currentPage: state.currentPage + 1,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadActivities();
  }

  Future<void> refresh() async {
    await loadActivities(refresh: true);
  }
}

/// Provider for all activities
final allActivitiesProvider =
    StateNotifierProvider<ActivityListNotifier, ActivityListState>((ref) {
      final activityApiService = ref.watch(activityApiServiceProvider);
      return ActivityListNotifier(activityApiService);
    });

/// Provider for my activities (current user's activities)
final myActivitiesProvider =
    StateNotifierProvider<ActivityListNotifier, ActivityListState>((ref) {
      final activityApiService = ref.watch(activityApiServiceProvider);
      final currentUser = ref.watch(currentUserProvider);
      return ActivityListNotifier(
        activityApiService,
        userIdFilter: currentUser?.id,
      );
    });

/// Provider for pending activities (admin/incharge view)
final pendingActivitiesProvider =
    StateNotifierProvider<ActivityListNotifier, ActivityListState>((ref) {
      final activityApiService = ref.watch(activityApiServiceProvider);
      return ActivityListNotifier(activityApiService, statusFilter: 'pending');
    });

/// State for activity detail
class ActivityDetailState {
  final Activity? activity;
  final bool isLoading;
  final String? error;

  ActivityDetailState({this.activity, this.isLoading = false, this.error});

  ActivityDetailState copyWith({
    Activity? activity,
    bool? isLoading,
    String? error,
  }) {
    return ActivityDetailState(
      activity: activity ?? this.activity,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Activity detail notifier
class ActivityDetailNotifier extends StateNotifier<ActivityDetailState> {
  final ActivityApiService _activityApiService;
  final int activityId;

  ActivityDetailNotifier(this._activityApiService, this.activityId)
    : super(ActivityDetailState(isLoading: true)) {
    loadActivity();
  }

  Future<void> loadActivity() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final activity = await _activityApiService.getActivityById(activityId);
      state = ActivityDetailState(activity: activity, isLoading: false);
    } catch (e) {
      state = ActivityDetailState(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyActivity() async {
    if (state.activity == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedActivity = await _activityApiService.verifyActivity(
        activityId,
      );
      state = ActivityDetailState(activity: updatedActivity, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> rejectActivity(String reason) async {
    if (state.activity == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedActivity = await _activityApiService.rejectActivity(
        activityId,
        reason,
      );
      state = ActivityDetailState(activity: updatedActivity, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteActivity() async {
    if (state.activity == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _activityApiService.deleteActivity(activityId);
      state = ActivityDetailState(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Provider for activity detail
final activityDetailProvider =
    StateNotifierProvider.family<
      ActivityDetailNotifier,
      ActivityDetailState,
      int
    >((ref, activityId) {
      final activityApiService = ref.watch(activityApiServiceProvider);
      return ActivityDetailNotifier(activityApiService, activityId);
    });

/// State for create activity
class CreateActivityState {
  final bool isLoading;
  final String? error;
  final Activity? createdActivity;

  CreateActivityState({
    this.isLoading = false,
    this.error,
    this.createdActivity,
  });

  CreateActivityState copyWith({
    bool? isLoading,
    String? error,
    Activity? createdActivity,
  }) {
    return CreateActivityState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      createdActivity: createdActivity ?? this.createdActivity,
    );
  }
}

/// Create activity notifier
class CreateActivityNotifier extends StateNotifier<CreateActivityState> {
  final ActivityApiService _activityApiService;

  CreateActivityNotifier(this._activityApiService)
    : super(CreateActivityState());

  Future<bool> createActivity(CreateActivityRequest request) async {
    state = CreateActivityState(isLoading: true);

    try {
      final activity = await _activityApiService.createActivity(request);
      state = CreateActivityState(createdActivity: activity);
      return true;
    } catch (e) {
      state = CreateActivityState(error: e.toString());
      return false;
    }
  }

  Future<List<String>> uploadMediaFiles(List<String> filePaths) async {
    try {
      return await _activityApiService.uploadMediaFiles(filePaths);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  void reset() {
    state = CreateActivityState();
  }
}

/// Provider for create activity
final createActivityProvider =
    StateNotifierProvider<CreateActivityNotifier, CreateActivityState>((ref) {
      final activityApiService = ref.watch(activityApiServiceProvider);
      return CreateActivityNotifier(activityApiService);
    });
