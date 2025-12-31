import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

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
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization token if available
          final token = await _storageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          _logger.d(
            'REQUEST[${options.method}] => PATH: ${options.path}\n'
            'Headers: ${options.headers}\n'
            'Data: ${options.data}',
          );

          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}\n'
            'Data: ${response.data}',
          );
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logger.e(
            'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}\n'
            'Message: ${error.message}\n'
            'Data: ${error.response?.data}',
          );

          // Handle 401 Unauthorized - token expired
          if (error.response?.statusCode == 401) {
            // Clear tokens and force re-login
            await _storageService.clearAll();
            // TODO: Navigate to login screen
            // This should be handled by a global navigation service or observer
          }

          return handler.next(error);
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        request: false,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: false,
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
