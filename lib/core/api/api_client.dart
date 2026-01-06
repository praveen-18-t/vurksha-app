/// HTTP Client with interceptors for authentication, retry, and error handling
///
/// Features:
/// - Automatic token refresh
/// - Request/response logging
/// - Retry on network errors
/// - Request ID tracking
/// - Error transformation

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'api_config.dart';
import 'token_storage.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();
  final Uuid _uuid = const Uuid();

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _RequestIdInterceptor(_uuid),
      _AuthInterceptor(_tokenStorage, _dio),
      _RetryInterceptor(_dio),
      if (kDebugMode) _LoggingInterceptor(),
    ]);
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Set auth tokens after login
  Future<void> setAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Clear auth tokens on logout
  Future<void> clearAuthTokens() async {
    await _tokenStorage.clearTokens();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _tokenStorage.hasValidToken();
  }
}

/// Adds unique request ID to each request
class _RequestIdInterceptor extends Interceptor {
  final Uuid _uuid;

  _RequestIdInterceptor(this._uuid);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Request-ID'] = _uuid.v4();
    handler.next(options);
  }
}

/// Handles authentication token injection and refresh
class _AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<Function(String)> _pendingRequests = [];

  _AuthInterceptor(this._tokenStorage, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !_isPublicEndpoint(err.requestOptions.path)) {
      // Token expired, try to refresh
      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          final refreshToken = await _tokenStorage.getRefreshToken();
          if (refreshToken != null) {
            final response = await _dio.post(
              '${ApiConfig.authEndpoint}/token/refresh',
              data: {'refreshToken': refreshToken},
              options: Options(
                headers: {'Authorization': ''},
              ), // No auth header
            );

            if (response.statusCode == 200) {
              final newAccessToken =
                  response.data['data']['accessToken'] as String;
              final newRefreshToken =
                  response.data['data']['refreshToken'] as String;

              await _tokenStorage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              // Retry pending requests
              for (final callback in _pendingRequests) {
                callback(newAccessToken);
              }
              _pendingRequests.clear();

              // Retry original request
              err.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              final retryResponse = await _dio.fetch(err.requestOptions);
              handler.resolve(retryResponse);
              return;
            }
          }
        } catch (e) {
          // Refresh failed, clear tokens
          await _tokenStorage.clearTokens();
        } finally {
          _isRefreshing = false;
        }
      } else {
        // Another request is already refreshing, queue this one
        _pendingRequests.add((token) async {
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          // Request will be retried by the first refresh
        });
      }
    }
    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    final publicPaths = [
      '/api/v1/auth/otp/send',
      '/api/v1/auth/otp/verify',
      '/api/v1/products',
      '/api/v1/categories',
      '/api/v1/banners',
      '/health',
    ];
    return publicPaths.any((p) => path.contains(p));
  }
}

/// Retries failed requests on network errors
class _RetryInterceptor extends Interceptor {
  final Dio _dio;

  _RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < ApiConfig.maxRetries) {
        await Future.delayed(ApiConfig.retryDelay * (retryCount + 1));

        err.requestOptions.extra['retryCount'] = retryCount + 1;

        try {
          final response = await _dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Fall through to handler.next
        }
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

/// Logs requests and responses in debug mode
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.uri}');
    if (options.data != null) {
      debugPrint('  Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '✗ ${err.response?.statusCode ?? 'ERROR'} ${err.requestOptions.uri}',
    );
    debugPrint('  ${err.message}');
    handler.next(err);
  }
}

/// API Exception for consistent error handling
class ApiException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;
  final String? requestId;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.errorCode,
    this.statusCode,
    this.requestId,
    this.originalError,
  });

  factory ApiException.fromDioError(DioException error) {
    String message = 'An unexpected error occurred';
    String? errorCode;
    String? requestId;

    if (error.response?.data is Map<String, dynamic>) {
      final data = error.response!.data as Map<String, dynamic>;
      message = data['error']?['message'] as String? ?? message;
      errorCode = data['error']?['code'] as String?;
      requestId = data['requestId'] as String?;
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Connection timed out. Please try again.';
          errorCode = 'TIMEOUT';
          break;
        case DioExceptionType.connectionError:
          message = 'No internet connection. Please check your network.';
          errorCode = 'NO_NETWORK';
          break;
        default:
          break;
      }
    }

    return ApiException(
      message: message,
      errorCode: errorCode,
      statusCode: error.response?.statusCode,
      requestId: requestId,
      originalError: error,
    );
  }

  @override
  String toString() => 'ApiException: $message (code: $errorCode)';
}
