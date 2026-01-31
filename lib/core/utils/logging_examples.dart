/// Example usage of the AppLogger system
///
/// This file demonstrates how to use the centralized logging system
/// throughout the application for debugging and error tracking.

import '../utils/app_logger.dart';

class LoggingExamples {
  final _logger = appLogger;

  /// Example 1: Basic logging
  void basicLogging() {
    // Debug message (only in debug mode)
    _logger.debug('This is a debug message');

    // Info message
    _logger.info('User completed task');

    // Warning message
    _logger.warning('Low memory warning');

    // Error message
    try {
      throw Exception('Something went wrong');
    } catch (e, stackTrace) {
      _logger.error('Operation failed', error: e, stackTrace: stackTrace);
    }
  }

  /// Example 2: Logging with tags
  void loggingWithTags() {
    // Use tags to identify the source of logs
    _logger.debug('Initializing component', tag: 'MyComponent');
    _logger.info('Data loaded successfully', tag: 'DataService');
    _logger.warning('Cache miss', tag: 'CacheManager');
    _logger.error(
      'Network timeout',
      tag: 'APIClient',
      error: 'Timeout after 30s',
    );
  }

  /// Example 3: Logging with additional data
  void loggingWithData() {
    _logger.debug(
      'Processing user request',
      tag: 'RequestHandler',
      data: {
        'userId': 123,
        'action': 'update_profile',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    _logger.info(
      'Transaction completed',
      tag: 'PaymentService',
      data: {'amount': 99.99, 'currency': 'USD', 'transactionId': 'tx_12345'},
    );
  }

  /// Example 4: Logging user actions
  void loggingUserActions() {
    _logger.logUserAction(
      'Login',
      details: {'username': 'john@example.com', 'timestamp': DateTime.now()},
    );

    _logger.logUserAction(
      'Create Activity',
      details: {'activityType': 'meeting', 'title': 'Team Standup'},
    );

    _logger.logUserAction('Logout');
  }

  /// Example 5: Logging navigation
  void loggingNavigation() {
    _logger.logNavigation('/home');
    _logger.logNavigation('/activities/123', params: {'id': '123'});
    _logger.logNavigation(
      '/profile/edit',
      params: {'userId': '456', 'section': 'personal-info'},
    );
  }

  /// Example 6: Logging state changes (for providers)
  void loggingStateChanges() {
    final oldState = {'isLoading': false, 'data': null};
    final newState = {'isLoading': true, 'data': null};

    _logger.logStateChange('UserProvider', oldState, newState);
  }

  /// Example 7: Error handling in API calls
  Future<void> apiCallWithLogging() async {
    _logger.info('Starting API call', tag: 'MyService');

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // The LoggingInterceptor will automatically log:
      // - Request details (method, URL, headers, body)
      // - Response details (status, data)
      // - Errors (if any)

      _logger.info('API call completed successfully', tag: 'MyService');
    } catch (e, stackTrace) {
      _logger.error(
        'API call failed',
        tag: 'MyService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Example 8: Logging in error boundaries
  void errorBoundaryLogging() {
    try {
      // Some risky operation
      throw Exception('Critical error occurred');
    } catch (e, stackTrace) {
      _logger.error(
        'Unhandled exception in ErrorBoundary',
        tag: 'ErrorBoundary',
        error: e,
        stackTrace: stackTrace,
        data: {
          'screen': 'DashboardScreen',
          'widget': 'StatsCard',
          'userId': 123,
        },
      );
    }
  }
}

/// Best Practices:
/// 
/// 1. Always use tags to identify log sources:
///    _logger.debug('Message', tag: 'ClassName');
/// 
/// 2. Include stack traces for errors:
///    _logger.error('Error', error: e, stackTrace: stackTrace);
/// 
/// 3. Add context with data parameter:
///    _logger.info('Event', tag: 'Service', data: {'key': 'value'});
/// 
/// 4. Use appropriate log levels:
///    - debug: Development debugging (not in production)
///    - info: Important events and milestones
///    - warning: Potential issues that don't stop execution
///    - error: Errors and exceptions that need attention
/// 
/// 5. Log user actions for analytics:
///    _logger.logUserAction('ActionName', details: {...});
/// 
/// 6. Log navigation for flow tracking:
///    _logger.logNavigation('/route', params: {...});
/// 
/// 7. HTTP requests/responses are automatically logged by LoggingInterceptor
/// 
/// 8. Logs are formatted with emojis and colors in debug mode for easy reading
