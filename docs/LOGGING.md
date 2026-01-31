# Logging System Documentation

## Overview

The Scout app now includes a comprehensive, centralized logging system for better debugging and error tracking. The system provides structured logging with multiple severity levels, automatic HTTP request/response logging, and detailed error information.

## Features

- **Structured Logging**: Consistent format with tags, timestamps, and emojis
- **Multiple Log Levels**: Debug, Info, Warning, Error
- **Automatic HTTP Logging**: All API requests/responses are logged automatically
- **Rich Error Details**: Includes stack traces, error types, and context
- **Environment Aware**: Debug logs only in debug mode, production-safe
- **User Action Tracking**: Track user interactions
- **Navigation Logging**: Monitor app navigation flow
- **State Change Tracking**: Log provider state changes

## Components

### 1. AppLogger (`lib/core/utils/app_logger.dart`)

Main logging utility class with methods for different log levels.

```dart
import '../core/utils/app_logger.dart';

final logger = appLogger; // Global instance

// Basic logging
logger.debug('Debug message');
logger.info('Info message');
logger.warning('Warning message');
logger.error('Error occurred', error: e, stackTrace: stackTrace);

// Logging with tags
logger.info('User logged in', tag: 'AuthService');

// Logging with additional data
logger.debug('Processing request', tag: 'API', data: {'userId': 123});
```

### 2. LoggingInterceptor (`lib/core/network/logging_interceptor.dart`)

Dio interceptor that automatically logs all HTTP requests and responses.

**Features:**

- Logs request method, URL, headers, and body
- Logs response status, headers, and data
- Logs errors with full details
- Formats output in readable boxes

**Automatically logs:**

- ✅ All HTTP requests
- ✅ All HTTP responses
- ❌ All HTTP errors

### 3. Enhanced DioClient

Updated to use the new logging system with better error tracking.

## Log Levels

| Level       | Use Case                              | Production |
| ----------- | ------------------------------------- | ---------- |
| **Debug**   | Development debugging, verbose output | ❌ Hidden  |
| **Info**    | Important events, milestones          | ✅ Shown   |
| **Warning** | Potential issues, non-critical        | ✅ Shown   |
| **Error**   | Errors, exceptions, failures          | ✅ Shown   |

## Usage Examples

### Basic Error Logging

```dart
try {
  await someOperation();
} catch (e, stackTrace) {
  appLogger.error(
    'Operation failed',
    tag: 'MyService',
    error: e,
    stackTrace: stackTrace,
  );
}
```

### API Call Logging

```dart
// Automatic logging via LoggingInterceptor
Future<List<Activity>> getActivities() async {
  // Request is automatically logged
  final response = await _dio.get('/api/activities');
  // Response is automatically logged
  return parseActivities(response.data);
}
```

### User Action Tracking

```dart
appLogger.logUserAction(
  'Create Activity',
  details: {
    'activityType': 'meeting',
    'title': 'Team Standup',
    'userId': 123,
  },
);
```

### Navigation Tracking

```dart
appLogger.logNavigation('/activities/123', params: {'id': '123'});
```

### State Change Logging

```dart
appLogger.logStateChange(
  'ActivityProvider',
  oldState,
  newState,
);
```

## HTTP Request/Response Logs

The LoggingInterceptor automatically formats HTTP logs:

```
┌─────────────────────────────────────────────────
│ 🌐 HTTP REQUEST
├─────────────────────────────────────────────────
│ Method: GET
│ URL: http://localhost:8000/api/activities
│ Headers: {Authorization: Bearer xxx, ...}
│ Query Params: {page: 1, limit: 20}
└─────────────────────────────────────────────────

┌─────────────────────────────────────────────────
│ ✅ HTTP RESPONSE
├─────────────────────────────────────────────────
│ Status: 200 OK
│ URL: http://localhost:8000/api/activities
│ Method: GET
│ Data: [{id: 1, title: '...'}]
└─────────────────────────────────────────────────
```

## Error Logs

Error logs include comprehensive details:

```
┌─────────────────────────────────────────────────
│ ❌ HTTP ERROR
├─────────────────────────────────────────────────
│ Type: DioExceptionType.badResponse
│ Message: Http status error [404]
│ URL: http://localhost:8000/api/activities/999
│ Method: GET
│ Status Code: 404
│ Response Data: {error: 'Not Found'}
│ Stack Trace: ...
└─────────────────────────────────────────────────
```

## Integration with Existing Code

The logging system has been integrated into:

1. **DioClient** - All HTTP requests/responses
2. **ActivityApiService** - Activity CRUD operations
3. **AuthProvider** - Authentication flow
4. **ActivityProvider** - Activity list management

## Best Practices

### ✅ DO

- Use tags to identify log sources
- Include stack traces for errors
- Add context with data parameter
- Use appropriate log levels
- Log user actions for analytics
- Log navigation for flow tracking

### ❌ DON'T

- Log sensitive information (passwords, tokens)
- Use debug logs for critical info in production
- Log excessive data in production
- Forget to include error and stackTrace in error logs

## Example Implementation

```dart
class MyService {
  final _logger = appLogger;

  Future<void> processData() async {
    _logger.debug('Starting data processing', tag: 'MyService');

    try {
      _logger.info('Fetching data from API', tag: 'MyService');
      final data = await fetchData();

      _logger.info(
        'Processing ${data.length} items',
        tag: 'MyService',
        data: {'count': data.length},
      );

      // Process data...

      _logger.info('Data processing completed', tag: 'MyService');
      _logger.logUserAction('Process Data', details: {'itemCount': data.length});

    } catch (e, stackTrace) {
      _logger.error(
        'Data processing failed',
        tag: 'MyService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
```

## Viewing Logs

### Development

- Logs appear in the IDE console with colors and emojis
- Debug logs are visible
- HTTP requests/responses shown in detail

### Production

- Only Info, Warning, and Error logs
- Debug logs are hidden
- Sensitive data is not logged

## Troubleshooting

**Q: Logs not appearing?**

- Check if running in debug mode
- Verify logger is imported: `import '../core/utils/app_logger.dart';`

**Q: Too many logs?**

- Adjust log level in AppLogger initialization
- Use tags to filter logs in IDE

**Q: Need more detail in error logs?**

- Always pass `error` and `stackTrace` parameters
- Add relevant data with `data` parameter

## Future Enhancements

- [ ] Remote logging service integration
- [ ] Log file persistence
- [ ] Crash reporting integration
- [ ] Performance monitoring
- [ ] Custom log filters
- [ ] Log export functionality
