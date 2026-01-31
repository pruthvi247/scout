import 'package:dio/dio.dart';
import '../utils/app_logger.dart';

/// Interceptor for logging HTTP requests and responses
/// Automatically logs all API calls with detailed information
class LoggingInterceptor extends Interceptor {
  final AppLogger _logger = appLogger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.logRequest(options);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.logResponse(response);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.logApiError(err);
    super.onError(err, handler);
  }
}
