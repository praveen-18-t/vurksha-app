import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_config.dart';
import '../models/order_model.dart';

class OrderRepository {
  final ApiClient _client = ApiClient.instance;

  /// Create a new order
  Future<Order> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _client.post(
        ApiConfig.ordersEndpoint,
        data: orderData,
        options: Options(
          headers: {
            // Idempotency key for safe retries
            'X-Idempotency-Key': DateTime.now().millisecondsSinceEpoch
                .toString(),
          },
        ),
      );

      final apiResponse = ApiResponse<Order>.fromJson(
        response.data,
        (data) => Order.fromJson(data['order'] as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.error ?? 'Failed to create order',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get user's orders
  Future<List<Order>> getOrders({int page = 1, int limit = 20}) async {
    try {
      final response = await _client.get(
        ApiConfig.ordersEndpoint,
        queryParameters: {'page': page, 'limit': limit},
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => data['orders'] as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((json) => Order.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get order details
  Future<Order> getOrderById(String id) async {
    try {
      final response = await _client.get('${ApiConfig.ordersEndpoint}/$id');

      final apiResponse = ApiResponse<Order>.fromJson(
        response.data,
        (data) => Order.fromJson(data['order'] as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(message: apiResponse.error ?? 'Order not found');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String id, String reason) async {
    try {
      await _client.post(
        '${ApiConfig.ordersEndpoint}/$id/cancel',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
