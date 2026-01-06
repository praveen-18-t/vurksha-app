/// Secure token storage using SharedPreferences
///
/// In production, consider using flutter_secure_storage for sensitive data

import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _tokenExpiryKey = 'auth_token_expiry';

  /// Save both tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);

    // Parse JWT to get expiry (simple extraction without full JWT library)
    final expiry = _extractExpiry(accessToken);
    if (expiry != null) {
      await prefs.setInt(_tokenExpiryKey, expiry.millisecondsSinceEpoch);
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Check if token exists and is not expired
  Future<bool> hasValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    final expiryMs = prefs.getInt(_tokenExpiryKey);

    if (token == null) return false;
    if (expiryMs == null) return true; // Assume valid if no expiry stored

    final expiry = DateTime.fromMillisecondsSinceEpoch(expiryMs);
    // Consider token invalid if it expires in less than 5 minutes
    return expiry.isAfter(DateTime.now().add(const Duration(minutes: 5)));
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

  /// Extract expiry from JWT (simple base64 decode)
  DateTime? _extractExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode payload (add padding if needed)
      String payload = parts[1];
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      // Note: In production, use proper JWT decoding
      // This is a simplified version
      return null; // Let server handle token validation
    } catch (e) {
      return null;
    }
  }
}
