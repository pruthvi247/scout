import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dashboard_api_service.dart';
import '../../../core/providers/network_providers.dart';
import '../../../models/dashboard_model.dart';

// Dashboard Stats State
class DashboardStatsState {
  final DashboardStats? stats;
  final bool isLoading;
  final String? error;

  DashboardStatsState({this.stats, this.isLoading = false, this.error});

  DashboardStatsState copyWith({
    DashboardStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return DashboardStatsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Dashboard Stats Notifier
class DashboardStatsNotifier extends StateNotifier<DashboardStatsState> {
  final DashboardApiService _apiService;

  DashboardStatsNotifier(this._apiService) : super(DashboardStatsState());

  Future<void> loadStats({
    String? organizationLevel,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stats = await _apiService.getDashboardStats(
        organizationLevel: organizationLevel,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh({
    String? organizationLevel,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await loadStats(
      organizationLevel: organizationLevel,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

// Member Stats State
class MemberStatsState {
  final MemberStats? stats;
  final bool isLoading;
  final String? error;

  MemberStatsState({this.stats, this.isLoading = false, this.error});

  MemberStatsState copyWith({
    MemberStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return MemberStatsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Member Stats Notifier
class MemberStatsNotifier extends StateNotifier<MemberStatsState> {
  final DashboardApiService _apiService;

  MemberStatsNotifier(this._apiService) : super(MemberStatsState());

  Future<void> loadStats({String? organizationLevel, String? role}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stats = await _apiService.getMemberStats(
        organizationLevel: organizationLevel,
        role: role,
      );

      state = state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Engagement Metrics State
class EngagementMetricsState {
  final EngagementMetrics? metrics;
  final bool isLoading;
  final String? error;

  EngagementMetricsState({this.metrics, this.isLoading = false, this.error});

  EngagementMetricsState copyWith({
    EngagementMetrics? metrics,
    bool? isLoading,
    String? error,
  }) {
    return EngagementMetricsState(
      metrics: metrics ?? this.metrics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Engagement Metrics Notifier
class EngagementMetricsNotifier extends StateNotifier<EngagementMetricsState> {
  final DashboardApiService _apiService;

  EngagementMetricsNotifier(this._apiService) : super(EngagementMetricsState());

  Future<void> loadMetrics({
    String? organizationLevel,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final metrics = await _apiService.getEngagementMetrics(
        organizationLevel: organizationLevel,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(metrics: metrics, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// API Service Provider
final dashboardApiServiceProvider = Provider<DashboardApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardApiService(dio);
});

// Providers
final dashboardStatsProvider =
    StateNotifierProvider<DashboardStatsNotifier, DashboardStatsState>((ref) {
      final apiService = ref.watch(dashboardApiServiceProvider);
      final notifier = DashboardStatsNotifier(apiService);
      notifier.loadStats(); // Auto-load on first access
      return notifier;
    });

final memberStatsProvider =
    StateNotifierProvider<MemberStatsNotifier, MemberStatsState>((ref) {
      final apiService = ref.watch(dashboardApiServiceProvider);
      final notifier = MemberStatsNotifier(apiService);
      notifier.loadStats(); // Auto-load on first access
      return notifier;
    });

final engagementMetricsProvider =
    StateNotifierProvider<EngagementMetricsNotifier, EngagementMetricsState>((
      ref,
    ) {
      final apiService = ref.watch(dashboardApiServiceProvider);
      final notifier = EngagementMetricsNotifier(apiService);
      notifier.loadMetrics(); // Auto-load on first access
      return notifier;
    });
