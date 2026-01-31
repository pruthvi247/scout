import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/volunteer_api_service.dart';
import '../../../core/providers/network_providers.dart';
import '../../../models/volunteer_model.dart';

// Volunteers List State
class VolunteersListState {
  final List<VolunteerProfile> volunteers;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  VolunteersListState({
    this.volunteers = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  VolunteersListState copyWith({
    List<VolunteerProfile>? volunteers,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return VolunteersListState(
      volunteers: volunteers ?? this.volunteers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Volunteers List Notifier
class VolunteersListNotifier extends StateNotifier<VolunteersListState> {
  final VolunteerApiService _apiService;

  VolunteersListNotifier(this._apiService) : super(VolunteersListState());

  Future<void> loadVolunteers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.getVolunteers(page: 1);

      state = state.copyWith(
        volunteers: result['volunteers'] as List<VolunteerProfile>,
        hasMore: result['hasMore'] as bool,
        currentPage: 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoading: true);

    try {
      final result = await _apiService.getVolunteers(page: nextPage);

      final newVolunteers = [
        ...state.volunteers,
        ...result['volunteers'] as List<VolunteerProfile>,
      ];

      state = state.copyWith(
        volunteers: newVolunteers,
        hasMore: result['hasMore'] as bool,
        currentPage: nextPage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadVolunteers();
  }
}

// Volunteer Assignments State
class VolunteerAssignmentsState {
  final List<Assignment> assignments;
  final bool isLoading;
  final String? error;

  VolunteerAssignmentsState({
    this.assignments = const [],
    this.isLoading = false,
    this.error,
  });

  VolunteerAssignmentsState copyWith({
    List<Assignment>? assignments,
    bool? isLoading,
    String? error,
  }) {
    return VolunteerAssignmentsState(
      assignments: assignments ?? this.assignments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Volunteer Assignments Notifier (Family Provider)
class VolunteerAssignmentsNotifier
    extends StateNotifier<VolunteerAssignmentsState> {
  final VolunteerApiService _apiService;
  final int volunteerId;

  VolunteerAssignmentsNotifier(this._apiService, this.volunteerId)
    : super(VolunteerAssignmentsState());

  Future<void> loadAssignments() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final assignments = await _apiService.getAssignments(volunteerId);

      state = state.copyWith(assignments: assignments, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateAssignmentStatus(int assignmentId, String status) async {
    try {
      await _apiService.updateAssignment(volunteerId, assignmentId, {
        'status': status,
      });

      // Reload assignments
      await loadAssignments();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Events List State
class EventsListState {
  final List<Event> events;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  EventsListState({
    this.events = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  EventsListState copyWith({
    List<Event>? events,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return EventsListState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Events List Notifier
class EventsListNotifier extends StateNotifier<EventsListState> {
  final VolunteerApiService _apiService;
  String? _statusFilter;

  EventsListNotifier(this._apiService) : super(EventsListState());

  Future<void> loadEvents({String? status}) async {
    _statusFilter = status;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.getEvents(status: status, page: 1);

      state = state.copyWith(
        events: result['events'] as List<Event>,
        hasMore: result['hasMore'] as bool,
        currentPage: 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoading: true);

    try {
      final result = await _apiService.getEvents(
        status: _statusFilter,
        page: nextPage,
      );

      final newEvents = [...state.events, ...result['events'] as List<Event>];

      state = state.copyWith(
        events: newEvents,
        hasMore: result['hasMore'] as bool,
        currentPage: nextPage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadEvents(status: _statusFilter);
  }
}

// API Service Provider
final volunteerApiServiceProvider = Provider<VolunteerApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return VolunteerApiService(dio);
});

// Providers
final volunteersListProvider =
    StateNotifierProvider<VolunteersListNotifier, VolunteersListState>((ref) {
      final apiService = ref.watch(volunteerApiServiceProvider);
      final notifier = VolunteersListNotifier(apiService);
      notifier.loadVolunteers(); // Auto-load on first access
      return notifier;
    });

final volunteerAssignmentsProvider =
    StateNotifierProvider.family<
      VolunteerAssignmentsNotifier,
      VolunteerAssignmentsState,
      int
    >((ref, volunteerId) {
      final apiService = ref.watch(volunteerApiServiceProvider);
      final notifier = VolunteerAssignmentsNotifier(apiService, volunteerId);
      notifier.loadAssignments(); // Auto-load on first access
      return notifier;
    });

final eventsListProvider =
    StateNotifierProvider<EventsListNotifier, EventsListState>((ref) {
      final apiService = ref.watch(volunteerApiServiceProvider);
      final notifier = EventsListNotifier(apiService);
      notifier.loadEvents(); // Auto-load on first access
      return notifier;
    });
