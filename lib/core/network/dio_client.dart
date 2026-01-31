import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import 'logging_interceptor.dart';
import '../utils/app_logger.dart';

class DioClient {
  final Dio _dio;
  final SecureStorageService _storageService;
  final Logger _logger = Logger();

  DioClient(this._storageService)
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          sendTimeout: ApiConstants.sendTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _initializeInterceptors();
  }

  Dio get dio => _dio;

  void _initializeInterceptors() {
    // Add custom logging interceptor first
    _dio.interceptors.add(LoggingInterceptor());

    // Add authorization and error handling interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization token if available
          final token = await _storageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            appLogger.debug('Added auth token to request', tag: 'DioClient');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) async {
          appLogger.error(
            'HTTP Error occurred',
            tag: 'DioClient',
            error: error,
            stackTrace: error.stackTrace,
          );

          // Handle 401 Unauthorized - token expired
          if (error.response?.statusCode == 401) {
            appLogger.warning(
              'Unauthorized access - clearing tokens',
              tag: 'DioClient',
            );
            await _storageService.clearAll();
            // TODO: Navigate to login screen
            // This should be handled by a global navigation service or observer
          }

          return handler.next(error);
        },
      ),
    );
  }

  // Helper method for form-urlencoded requests (used for login)
  Future<Response> postFormUrlEncoded(
    String path,
    Map<String, dynamic> data,
  ) async {
    return await _dio.post(
      path,
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }
}
