/// API Configuration for Vurksha Backend
///
/// This file contains all configuration for connecting to the backend services.

class ApiConfig {
  // Base URL - change based on environment
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000', // Kong gateway in development
  );

  // API version
  static const String apiVersion = 'v1';

  // Full API base path
  static String get apiBasePath => '$baseUrl/api/$apiVersion';

  // Service endpoints
  static String get authEndpoint => '$apiBasePath/auth';
  static String get usersEndpoint => '$apiBasePath/users';
  static String get addressesEndpoint => '$apiBasePath/addresses';
  static String get productsEndpoint => '$apiBasePath/products';
  static String get categoriesEndpoint => '$apiBasePath/categories';
  static String get bannersEndpoint => '$apiBasePath/banners';
  static String get ordersEndpoint => '$apiBasePath/orders';
  static String get cartEndpoint => '$apiBasePath/cart';
  static String get notificationsEndpoint => '$apiBasePath/notifications';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Cache durations
  static const Duration productCacheDuration = Duration(minutes: 5);
  static const Duration categoryCacheDuration = Duration(minutes: 30);
  static const Duration bannerCacheDuration = Duration(minutes: 15);
}

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? errorCode;
  final String? requestId;
  final PaginationMeta? pagination;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.errorCode,
    this.requestId,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    final success = json['success'] as bool? ?? false;

    T? data;
    if (success && json['data'] != null && fromJsonT != null) {
      data = fromJsonT(json['data'] as Map<String, dynamic>);
    }

    PaginationMeta? pagination;
    if (json['pagination'] != null) {
      pagination = PaginationMeta.fromJson(
        json['pagination'] as Map<String, dynamic>,
      );
    }

    return ApiResponse(
      success: success,
      data: data,
      error: json['error']?['message'] as String?,
      errorCode: json['error']?['code'] as String?,
      requestId: json['requestId'] as String?,
      pagination: pagination,
    );
  }

  factory ApiResponse.error(String message, {String? code, String? requestId}) {
    return ApiResponse(
      success: false,
      error: message,
      errorCode: code,
      requestId: requestId,
    );
  }
}

/// Pagination metadata
class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    final page = json['page'] as int? ?? 1;
    final limit = json['limit'] as int? ?? 20;
    final total = json['total'] as int? ?? 0;
    final totalPages = (total / limit).ceil();

    return PaginationMeta(
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
      hasMore: page < totalPages,
    );
  }
}
