import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

/// Centralized logging utility for the application
/// Provides structured logging with different levels and better error formatting
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  late final Logger _logger;

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal() {
    _logger = Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      level: kDebugMode ? Level.debug : Level.info,
    );
  }

  /// Log debug messages (only in debug mode)
  void debug(String message, {String? tag, dynamic data}) {
    final formattedMessage = _formatMessage(message, tag, data);
    _logger.d(formattedMessage);
  }

  /// Log informational messages
  void info(String message, {String? tag, dynamic data}) {
    final formattedMessage = _formatMessage(message, tag, data);
    _logger.i(formattedMessage);
  }

  /// Log warning messages
  void warning(String message, {String? tag, dynamic data}) {
    final formattedMessage = _formatMessage(message, tag, data);
    _logger.w(formattedMessage);
  }

  /// Log error messages with detailed error information
  void error(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
    dynamic data,
  }) {
    final formattedMessage = _formatMessage(message, tag, data);
    final errorDetails = _formatError(error);

    _logger.e(
      '$formattedMessage\n$errorDetails',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log API request details
  void logRequest(RequestOptions options) {
    if (!kDebugMode) return;

    final message = StringBuffer()
      ..writeln('┌─────────────────────────────────────────────────')
      ..writeln('│ 🌐 HTTP REQUEST')
      ..writeln('├─────────────────────────────────────────────────')
      ..writeln('│ Method: ${options.method}')
      ..writeln('│ URL: ${options.uri}')
      ..writeln('│ Headers: ${options.headers}')
      ..writeln('│ Query Params: ${options.queryParameters}');

    if (options.data != null) {
      message.writeln('│ Body: ${options.data}');
    }

    message.writeln('└─────────────────────────────────────────────────');

    _logger.d(message.toString());
  }

  /// Log API response details
  void logResponse(Response response) {
    if (!kDebugMode) return;

    final message = StringBuffer()
      ..writeln('┌─────────────────────────────────────────────────')
      ..writeln('│ ✅ HTTP RESPONSE')
      ..writeln('├─────────────────────────────────────────────────')
      ..writeln('│ Status: ${response.statusCode} ${response.statusMessage}')
      ..writeln('│ URL: ${response.requestOptions.uri}')
      ..writeln('│ Method: ${response.requestOptions.method}');

    if (response.data != null) {
      final dataStr = response.data.toString();
      final truncatedData = dataStr.length > 1000
          ? '${dataStr.substring(0, 1000)}... (truncated)'
          : dataStr;
      message.writeln('│ Data: $truncatedData');
    }

    message.writeln('└─────────────────────────────────────────────────');

    _logger.i(message.toString());
  }

  /// Log API error with detailed information
  void logApiError(DioException error) {
    final message = StringBuffer()
      ..writeln('┌─────────────────────────────────────────────────')
      ..writeln('│ ❌ HTTP ERROR')
      ..writeln('├─────────────────────────────────────────────────')
      ..writeln('│ Type: ${error.type}')
      ..writeln('│ Message: ${error.message}')
      ..writeln('│ URL: ${error.requestOptions.uri}')
      ..writeln('│ Method: ${error.requestOptions.method}');

    if (error.response != null) {
      message
        ..writeln('│ Status Code: ${error.response?.statusCode}')
        ..writeln('│ Status Message: ${error.response?.statusMessage}');

      if (error.response?.data != null) {
        message.writeln('│ Response Data: ${error.response?.data}');
      }
    }

    if (error.requestOptions.data != null) {
      message.writeln('│ Request Data: ${error.requestOptions.data}');
    }

    message
      ..writeln('│ Stack Trace: ${error.stackTrace}')
      ..writeln('└─────────────────────────────────────────────────');

    _logger.e(message.toString(), error: error, stackTrace: error.stackTrace);
  }

  /// Log navigation events
  void logNavigation(String route, {Map<String, dynamic>? params}) {
    final message = StringBuffer('🧭 Navigation → $route');
    if (params != null && params.isNotEmpty) {
      message.write(' | Params: $params');
    }
    _logger.i(message.toString());
  }

  /// Log state changes
  void logStateChange(String provider, dynamic oldState, dynamic newState) {
    if (!kDebugMode) return;

    final message = StringBuffer()
      ..writeln('🔄 State Change: $provider')
      ..writeln('   Old: $oldState')
      ..writeln('   New: $newState');

    _logger.d(message.toString());
  }

  /// Log user actions
  void logUserAction(String action, {Map<String, dynamic>? details}) {
    final message = StringBuffer('👤 User Action: $action');
    if (details != null && details.isNotEmpty) {
      message.write(' | Details: $details');
    }
    _logger.i(message.toString());
  }

  /// Format message with tag and data
  String _formatMessage(String message, String? tag, dynamic data) {
    final buffer = StringBuffer();

    if (tag != null) {
      buffer.write('[$tag] ');
    }

    buffer.write(message);

    if (data != null) {
      buffer.write(' | Data: $data');
    }

    return buffer.toString();
  }

  /// Format error details for better readability
  String _formatError(dynamic error) {
    if (error == null) return '';

    final buffer = StringBuffer()..writeln('Error Type: ${error.runtimeType}');

    if (error is DioException) {
      buffer
        ..writeln('DioException Details:')
        ..writeln('  Type: ${error.type}')
        ..writeln('  Message: ${error.message}')
        ..writeln('  URL: ${error.requestOptions.uri}')
        ..writeln('  Method: ${error.requestOptions.method}');

      if (error.response != null) {
        buffer
          ..writeln('  Status Code: ${error.response?.statusCode}')
          ..writeln('  Response Data: ${error.response?.data}');
      }
    } else if (error is Exception) {
      buffer.writeln('Exception: $error');
    } else {
      buffer.writeln('Error: $error');
    }

    return buffer.toString();
  }
}

/// Global logger instance
final appLogger = AppLogger();
