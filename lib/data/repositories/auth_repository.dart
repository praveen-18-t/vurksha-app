import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_config.dart';
import '../../core/api/token_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _client = ApiClient.instance;
  final TokenStorage _tokenStorage = TokenStorage();

  /// Send OTP to phone number
  Future<void> sendOtp(String phone) async {
    try {
      await _client.post(
        '${ApiConfig.authEndpoint}/send-otp',
        data: {'phone': phone},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Verify OTP and login
  Future<UserModel> verifyOtp(String phone, String otp) async {
    try {
      final response = await _client.post(
        '${ApiConfig.authEndpoint}/verify-otp',
        data: {'phone': phone, 'otp': otp},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final data = apiResponse.data!;

        // Save tokens
        if (data['accessToken'] != null && data['refreshToken'] != null) {
          await _tokenStorage.saveTokens(
            accessToken: data['accessToken'],
            refreshToken: data['refreshToken'],
          );
        }

        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }

      throw ApiException(message: apiResponse.error ?? 'Verification failed');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get current user profile
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _client.get('${ApiConfig.usersEndpoint}/profile');

      final apiResponse = ApiResponse<UserModel>.fromJson(
        response.data,
        (data) => UserModel.fromJson(data['user'] as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(message: apiResponse.error ?? 'User not found');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _client.post('${ApiConfig.authEndpoint}/logout');
    } catch (e) {
      // Ignore logout errors
    } finally {
      await _tokenStorage.clearTokens();
    }
  }
}
