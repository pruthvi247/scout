import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import '../../../core/providers/network_providers.dart';
import '../../../core/network/auth_api_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/utils/app_logger.dart';

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
      appLogger.debug('Checking authentication status', tag: 'AuthProvider');
      final isLoggedIn = await _storageService.isLoggedIn();

      if (isLoggedIn) {
        appLogger.info(
          'User is logged in, fetching user data',
          tag: 'AuthProvider',
        );
        final user = await _authApiService.getCurrentUser();
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        appLogger.info(
          'User authenticated: ${user.fullName}',
          tag: 'AuthProvider',
        );
      } else {
        appLogger.debug('No active session found', tag: 'AuthProvider');
        state = state.copyWith(isLoading: false);
      }
    } catch (e, stackTrace) {
      appLogger.error(
        'Auth status check failed',
        tag: 'AuthProvider',
        error: e,
        stackTrace: stackTrace,
      );
      // Token might be invalid, clear storage
      await _storageService.clearAll();
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Login with username and password
  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      appLogger.info(
        'Attempting login for user: $username',
        tag: 'AuthProvider',
      );

      // Call login API
      final loginResponse = await _authApiService.login(username, password);
      appLogger.debug('Login API response received', tag: 'AuthProvider');

      // Save tokens
      await _storageService.saveAccessToken(loginResponse.accessToken);
      if (loginResponse.refreshToken != null) {
        await _storageService.saveRefreshToken(loginResponse.refreshToken!);
      }
      appLogger.debug('Tokens saved to secure storage', tag: 'AuthProvider');

      // Get user profile
      final user = await _authApiService.getCurrentUser();
      appLogger.info(
        'User profile fetched: ${user.fullName} (${user.role})',
        tag: 'AuthProvider',
      );

      // Save user info
      await _storageService.saveUserId(user.id);
      await _storageService.saveUserRole(user.role);

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      appLogger.logUserAction(
        'Login',
        details: {'username': username, 'userId': user.id, 'role': user.role},
      );
    } catch (e, stackTrace) {
      appLogger.error(
        'Login failed for user: $username',
        tag: 'AuthProvider',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      appLogger.info('Logging out user', tag: 'AuthProvider');

      // Try to call logout API, but continue even if it fails
      // Backend may not have logout endpoint implemented
      try {
        await _authApiService.logout();
        appLogger.debug('Logout API call successful', tag: 'AuthProvider');
      } catch (e) {
        appLogger.warning(
          'Logout API call failed, continuing with local cleanup',
          tag: 'AuthProvider',
          error: e,
        );
        // Continue with local cleanup even if API call fails
      }

      // Clear local storage
      await _storageService.clearAll();
      appLogger.info('Local storage cleared', tag: 'AuthProvider');

      // Reset state
      state = const AuthState();

      appLogger.logUserAction('Logout');
    } catch (e, stackTrace) {
      appLogger.error(
        'Logout failed',
        tag: 'AuthProvider',
        error: e,
        stackTrace: stackTrace,
      );
      // Still clear storage and reset state even on error
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
