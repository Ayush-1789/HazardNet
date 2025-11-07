/// Base API service for making HTTP requests to the backend
/// Handles authentication tokens, error handling, and request/response formatting

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:event_safety_app/core/constants/app_constants.dart';

class ApiService {
  final http.Client _client;
  String? _authToken;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Set authentication token for API requests
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Get current auth token
  String? get authToken => _authToken;

  /// Build headers with authentication
  Map<String, String> _buildHeaders({Map<String, String>? additionalHeaders}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      Uri uri = Uri.parse('${AppConstants.baseApiUrl}$endpoint');
      
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await _client.get(
        uri,
        headers: _buildHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseApiUrl}$endpoint'),
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse('${AppConstants.baseApiUrl}$endpoint'),
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _client.patch(
        Uri.parse('${AppConstants.baseApiUrl}$endpoint'),
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('${AppConstants.baseApiUrl}$endpoint'),
        headers: _buildHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      // Success response
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (statusCode == 401) {
      // Unauthorized - token expired or invalid
      _authToken = null;
      throw ApiException(
        message: 'Authentication required. Please login again.',
        statusCode: 401,
      );
    } else if (statusCode == 403) {
      throw ApiException(
        message: 'Access forbidden.',
        statusCode: 403,
      );
    } else if (statusCode == 404) {
      throw ApiException(
        message: 'Resource not found.',
        statusCode: 404,
      );
    } else if (statusCode >= 500) {
      throw ApiException(
        message: 'Server error. Please try again later.',
        statusCode: statusCode,
      );
    } else {
      // Other errors
      final errorBody = jsonDecode(response.body);
      throw ApiException(
        message: errorBody['message'] ?? 'An error occurred.',
        statusCode: statusCode,
      );
    }
  }

  /// Handle errors
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    return ApiException(
      message: 'Network error. Please check your connection.',
      statusCode: 0,
    );
  }

  /// Close the HTTP client
  void dispose() {
    _client.close();
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
