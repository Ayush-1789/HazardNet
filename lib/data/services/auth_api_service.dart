/// Authentication API service
/// Handles user registration, login, logout, and token management

import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:event_safety_app/data/services/api_service.dart';
import 'package:event_safety_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApiService {
  final ApiService _apiService;
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  AuthApiService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Register new user
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
    String vehicleType = 'car',
  }) async {
    final response = await _apiService.post(
      AppConstants.authRegisterEndpoint,
      body: {
        'email': email,
        'password': password,
        'display_name': displayName,
        'phone_number': phoneNumber,
        'vehicle_type': vehicleType,
      },
    );

    // Save token and user info - validate response
    final token = response['token'];
    final userData = response['user'];

    if (token == null || userData == null) {
      throw Exception('Invalid response from server: missing token or user data');
    }

    final tokenStr = token.toString();
    final userMap = Map<String, dynamic>.from(userData as Map);

    await _saveAuthData(tokenStr, userMap['id'].toString());
    _apiService.setAuthToken(tokenStr);

    return UserModel.fromJson(userMap);
  }

  /// Login user
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      AppConstants.authLoginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
    );

    // Save token and user info - validate response
    final token = response['token'];
    final userData = response['user'];

    if (token == null || userData == null) {
      throw Exception('Invalid response from server: missing token or user data');
    }

    final tokenStr = token.toString();
    final userMap = Map<String, dynamic>.from(userData as Map);

    await _saveAuthData(tokenStr, userMap['id'].toString());
    _apiService.setAuthToken(tokenStr);

    return UserModel.fromJson(userMap);
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _apiService.post(AppConstants.authLogoutEndpoint);
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      await _clearAuthData();
      _apiService.setAuthToken(null);
    }
  }

  /// Check if user is authenticated
  Future<UserModel?> checkAuthStatus() async {
    final token = await _getStoredToken();
    
    if (token == null) {
      return null;
    }

    _apiService.setAuthToken(token);

    try {
      final response = await _apiService.get(AppConstants.authCheckEndpoint);
      final userData = response['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      // Token invalid or expired
      await _clearAuthData();
      _apiService.setAuthToken(null);
      return null;
    }
  }

  /// Get user profile
  Future<UserModel> getUserProfile() async {
    final response = await _apiService.get(AppConstants.userProfileEndpoint);
    final userData = response['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }

  /// Update damage score
  Future<void> updateDamageScore(int scoreIncrease) async {
    await _apiService.patch(
      AppConstants.updateDamageScoreEndpoint,
      body: {
        'damage_score_increase': scoreIncrease,
      },
    );
  }

  /// Save authentication data to local storage
  Future<void> _saveAuthData(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
  }

  /// Clear authentication data from local storage
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  /// Get stored auth token
  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get stored user ID
  Future<String?> getStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
}
