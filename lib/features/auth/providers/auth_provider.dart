import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import '../../../core/providers/network_providers.dart';
import '../../../core/network/auth_api_service.dart';
import '../../../core/storage/secure_storage_service.dart';

/// Authentication state
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Authentication notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApiService _authApiService;
  final SecureStorageService _storageService;

  AuthNotifier(this._authApiService, this._storageService)
    : super(const AuthState()) {
    _checkAuthStatus();
  }

  /// Check if user is already logged in on app start
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final isLoggedIn = await _storageService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authApiService.getCurrentUser();
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      // Token might be invalid, clear storage
      await _storageService.clearAll();
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Login with username and password
  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Call login API
      final loginResponse = await _authApiService.login(username, password);

      // Save tokens
      await _storageService.saveAccessToken(loginResponse.accessToken);
      if (loginResponse.refreshToken != null) {
        await _storageService.saveRefreshToken(loginResponse.refreshToken!);
      }

      // Get user profile
      final user = await _authApiService.getCurrentUser();

      // Save user info
      await _storageService.saveUserId(user.id);
      await _storageService.saveUserRole(user.role);

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      // Call logout API
      await _authApiService.logout();
    } catch (e) {
      // Continue logout even if API call fails
    } finally {
      // Clear local storage
      await _storageService.clearAll();
      state = const AuthState();
    }
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    try {
      final user = await _authApiService.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authApiService = ref.watch(authApiServiceProvider);
  final storageService = ref.watch(secureStorageServiceProvider);
  return AuthNotifier(authApiService, storageService);
});

/// Current user provider (convenience)
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Is authenticated provider (convenience)
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
