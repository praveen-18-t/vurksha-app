import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_config.dart';
import '../models/notification_model.dart';
import 'app_notification.dart';

class NotificationRepository {
  final ApiClient _client = ApiClient.instance;

  /// Fetch user notifications
  Future<List<AppNotification>> fetchNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.notificationsEndpoint,
        queryParameters: {'page': page, 'limit': limit},
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => data['notifications'] as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map(
              (json) => AppNotification.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get unread count
  Future<int> fetchUnreadCount() async {
    try {
      final response = await _client.get(
        '${ApiConfig.notificationsEndpoint}/unread-count',
      );
      final apiResponse = ApiResponse<int>.fromJson(
        response.data,
        (data) => data['count'] as int,
      );
      return apiResponse.data ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Mark notification as read
  Future<void> markRead(String id) async {
    try {
      await _client.post('${ApiConfig.notificationsEndpoint}/$id/read');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Mark all as read
  Future<void> markAllRead() async {
    try {
      await _client.post('${ApiConfig.notificationsEndpoint}/read-all');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Register device for push notifications
  Future<void> registerDevice(String token, String platform) async {
    try {
      await _client.post(
        '${ApiConfig.notificationsEndpoint}/devices',
        data: {'token': token, 'platform': platform},
      );
    } on DioException catch (e) {
      // Don't throw for device registration, just log
      print('Failed to register device: $e');
    }
  }
}
