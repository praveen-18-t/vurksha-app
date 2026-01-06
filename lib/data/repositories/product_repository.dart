import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_config.dart';
import '../models/product_model.dart';

class ProductRepository {
  final ApiClient _client = ApiClient.instance;

  /// Fetch all products with optional filtering
  Future<List<Product>> getProducts({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.productsEndpoint,
        queryParameters: {
          if (category != null) 'category': category,
          if (search != null) 'search': search,
          'page': page,
          'limit': limit,
        },
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => data['products'] as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        message: apiResponse.error ?? 'Failed to fetch products',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get single product details
  Future<Product> getProductById(String id) async {
    try {
      final response = await _client.get('${ApiConfig.productsEndpoint}/$id');

      final apiResponse = ApiResponse<Product>.fromJson(
        response.data,
        (data) => Product.fromJson(data['product'] as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(message: apiResponse.error ?? 'Product not found');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get product categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _client.get(ApiConfig.categoriesEndpoint);

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => data['categories'] as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!.cast<String>();
      }

      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
