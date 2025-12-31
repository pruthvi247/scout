import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/notification_api_service.dart';
import '../../../core/providers/network_providers.dart';
import '../../../models/notification_model.dart';

// Notifications List State
class NotificationsListState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  NotificationsListState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  NotificationsListState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return NotificationsListState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Notifications List Notifier
class NotificationsListNotifier extends StateNotifier<NotificationsListState> {
  final NotificationApiService _apiService;
  String? _typeFilter;
  String? _statusFilter;

  NotificationsListNotifier(this._apiService)
      : super(NotificationsListState());

  Future<void> loadNotifications({
    String? type,
    String? status,
  }) async {
    _typeFilter = type;
    _statusFilter = status;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.getNotifications(
        type: type,
        status: status,
        page: 1,
      );

      state = state.copyWith(
        notifications: result['notifications'] as List<NotificationModel>,
        hasMore: result['hasMore'] as bool,
        currentPage: 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoading: true);

    try {
      final result = await _apiService.getNotifications(
        type: _typeFilter,
        status: _statusFilter,
        page: nextPage,
      );

      final newNotifications = [
        ...state.notifications,
        ...result['notifications'] as List<NotificationModel>,
      ];

      state = state.copyWith(
        notifications: newNotifications,
        hasMore: result['hasMore'] as bool,
        currentPage: nextPage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadNotifications(type: _typeFilter, status: _statusFilter);
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiService.markAsRead(notificationId);

      // Update local state
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      // Handle error silently or show toast
    }
  }
}

// Unread Count State
class UnreadCountState {
  final int count;
  final bool isLoading;

  UnreadCountState({
    this.count = 0,
    this.isLoading = false,
  });

  UnreadCountState copyWith({
    int? count,
    bool? isLoading,
  }) {
    return UnreadCountState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Unread Count Notifier
class UnreadCountNotifier extends StateNotifier<UnreadCountState> {
  final NotificationApiService _apiService;

  UnreadCountNotifier(this._apiService) : super(UnreadCountState());

  Future<void> loadUnreadCount() async {
    state = state.copyWith(isLoading: true);

    try {
      final count = await _apiService.getUnreadCount();
      state = state.copyWith(count: count, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void decrementCount() {
    if (state.count > 0) {
      state = state.copyWith(count: state.count - 1);
    }
  }
}

// API Service Provider
final notificationApiServiceProvider =
    Provider<NotificationApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationApiService(dio);
});

// Providers
final notificationsListProvider = StateNotifierProvider<
    NotificationsListNotifier, NotificationsListState>((ref) {
  final apiService = ref.watch(notificationApiServiceProvider);
  final notifier = NotificationsListNotifier(apiService);
  notifier.loadNotifications(); // Auto-load on first access
  return notifier;
});

final unreadCountProvider =
    StateNotifierProvider<UnreadCountNotifier, UnreadCountState>((ref) {
  final apiService = ref.watch(notificationApiServiceProvider);
  final notifier = UnreadCountNotifier(apiService);
  notifier.loadUnreadCount(); // Auto-load on first access
  return notifier;
});
