import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/organization_api_service.dart';
import '../../../core/providers/network_providers.dart';
import '../../../models/organization_model.dart';

/// Provider for OrganizationApiService
final organizationApiServiceProvider = Provider<OrganizationApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return OrganizationApiService(dio);
});

/// State for organization tree
class OrganizationTreeState {
  final OrganizationTree? tree;
  final bool isLoading;
  final String? error;

  OrganizationTreeState({this.tree, this.isLoading = false, this.error});

  OrganizationTreeState copyWith({
    OrganizationTree? tree,
    bool? isLoading,
    String? error,
  }) {
    return OrganizationTreeState(
      tree: tree ?? this.tree,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Organization tree notifier
class OrganizationTreeNotifier extends StateNotifier<OrganizationTreeState> {
  final OrganizationApiService _organizationApiService;

  OrganizationTreeNotifier(this._organizationApiService)
    : super(OrganizationTreeState(isLoading: true)) {
    loadTree();
  }

  Future<void> loadTree() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tree = await _organizationApiService.getOrganizationTree();
      state = OrganizationTreeState(tree: tree, isLoading: false);
    } catch (e) {
      state = OrganizationTreeState(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadTree();
  }
}

/// Provider for organization tree
final organizationTreeProvider =
    StateNotifierProvider<OrganizationTreeNotifier, OrganizationTreeState>((
      ref,
    ) {
      final organizationApiService = ref.watch(organizationApiServiceProvider);
      return OrganizationTreeNotifier(organizationApiService);
    });
