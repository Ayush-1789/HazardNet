import 'package:http/http.dart' as http;

/// Smart Backend Configuration with Automatic Failover
/// Primary: Laptop (192.168.31.39:3000)
/// Fallback: AWS Cloud Backend
class ApiConfig {
  // Backend URLs
  static const String laptopBackendUrl = 'http://192.168.31.39:3000/api';
  static const String awsBackendUrl = 'https://your-aws-url.com/api'; // Will be updated after AWS deployment
  
  // Current active backend
  static String _currentBackendUrl = laptopBackendUrl;
  static bool _isUsingFallback = false;
  
  /// Get current backend URL
  static String get baseApiUrl => _currentBackendUrl;
  
  /// Check if using fallback (AWS)
  static bool get isUsingFallback => _isUsingFallback;
  
  /// Try to connect to backend with automatic failover
  static Future<String> getAvailableBackendUrl() async {
    try {
      // First, try laptop backend
      final laptopResponse = await _checkBackendHealth(laptopBackendUrl);
      if (laptopResponse) {
        _currentBackendUrl = laptopBackendUrl;
        _isUsingFallback = false;
        print('✅ Connected to Laptop Backend');
        return laptopBackendUrl;
      }
    } catch (e) {
      print('⚠️ Laptop backend not available: $e');
    }
    
    try {
      // Fallback to AWS backend
      final awsResponse = await _checkBackendHealth(awsBackendUrl);
      if (awsResponse) {
        _currentBackendUrl = awsBackendUrl;
        _isUsingFallback = true;
        print('✅ Connected to AWS Backend (Fallback)');
        return awsBackendUrl;
      }
    } catch (e) {
      print('❌ AWS backend not available: $e');
    }
    
    // If both fail, default to laptop (will show error in app)
    _currentBackendUrl = laptopBackendUrl;
    _isUsingFallback = false;
    return laptopBackendUrl;
  }
  
  /// Check if backend is healthy
  static Future<bool> _checkBackendHealth(String baseUrl) async {
    try {
      final healthUrl = baseUrl.replaceAll('/api', '/health');
      final response = await http.get(
        Uri.parse(healthUrl),
      ).timeout(const Duration(seconds: 3));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Force switch to specific backend
  static void useBackend(BackendType type) {
    switch (type) {
      case BackendType.laptop:
        _currentBackendUrl = laptopBackendUrl;
        _isUsingFallback = false;
        break;
      case BackendType.aws:
        _currentBackendUrl = awsBackendUrl;
        _isUsingFallback = true;
        break;
    }
  }
  
  /// Get backend status
  static Future<BackendStatus> getBackendStatus() async {
    final laptopAvailable = await _checkBackendHealth(laptopBackendUrl);
    final awsAvailable = await _checkBackendHealth(awsBackendUrl);
    
    return BackendStatus(
      laptopAvailable: laptopAvailable,
      awsAvailable: awsAvailable,
      currentBackend: _isUsingFallback ? BackendType.aws : BackendType.laptop,
    );
  }
}

enum BackendType {
  laptop,
  aws,
}

class BackendStatus {
  final bool laptopAvailable;
  final bool awsAvailable;
  final BackendType currentBackend;
  
  BackendStatus({
    required this.laptopAvailable,
    required this.awsAvailable,
    required this.currentBackend,
  });
  
  String get statusMessage {
    if (laptopAvailable && awsAvailable) {
      return '✅ Both backends available';
    } else if (laptopAvailable) {
      return '✅ Laptop backend available';
    } else if (awsAvailable) {
      return '⚠️ Using AWS backup (laptop offline)';
    } else {
      return '❌ No backend available';
    }
  }
}
