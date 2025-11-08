import 'package:http/http.dart' as http;

/// Smart Backend Configuration with Triple Failover System
/// Priority 1: Laptop (192.168.31.39:3000) - Fastest, Free
/// Priority 2: Railway (Cloud) - Free, Always On
/// Priority 3: AWS (Cloud) - Backup, Uses Credits
class ApiConfig {
  // Backend URLs - Priority Order
  static const String laptopBackendUrl = 'http://192.168.31.39:3000/api';
  static const String railwayBackendUrl = 'https://hazardnet-9yd2.onrender.com/api';
  static const String awsBackendUrl = 'https://your-aws-url.com/api'; // Will be updated after AWS deployment
  
  // Current active backend
  static String _currentBackendUrl = laptopBackendUrl;
  static BackendType _currentBackendType = BackendType.laptop;
  
  /// Get current backend URL
  static String get baseApiUrl => _currentBackendUrl;
  
  /// Get current backend type
  static BackendType get currentBackendType => _currentBackendType;
  
  /// Try to connect to backend with automatic triple failover
  static Future<String> getAvailableBackendUrl() async {
    // Priority 1: Try Laptop (fastest, free, local)
    try {
      final laptopResponse = await _checkBackendHealth(laptopBackendUrl);
      if (laptopResponse) {
        _currentBackendUrl = laptopBackendUrl;
        _currentBackendType = BackendType.laptop;
        print('✅ Connected to Laptop Backend (Primary)');
        return laptopBackendUrl;
      }
    } catch (e) {
      print('⚠️ Laptop backend not available: $e');
    }
    
    // Priority 2: Try Railway (free, always on)
    try {
      final railwayResponse = await _checkBackendHealth(railwayBackendUrl);
      if (railwayResponse) {
        _currentBackendUrl = railwayBackendUrl;
        _currentBackendType = BackendType.railway;
        print('✅ Connected to Railway Backend (Fallback 1)');
        return railwayBackendUrl;
      }
    } catch (e) {
      print('⚠️ Railway backend not available: $e');
    }
    
    // Priority 3: Try AWS (backup, uses credits)
    try {
      final awsResponse = await _checkBackendHealth(awsBackendUrl);
      if (awsResponse) {
        _currentBackendUrl = awsBackendUrl;
        _currentBackendType = BackendType.aws;
        print('✅ Connected to AWS Backend (Fallback 2)');
        return awsBackendUrl;
      }
    } catch (e) {
      print('❌ AWS backend not available: $e');
    }
    
    // If all fail, default to laptop (will show error in app)
    _currentBackendUrl = laptopBackendUrl;
    _currentBackendType = BackendType.laptop;
    print('❌ All backends unavailable, defaulting to laptop');
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
        _currentBackendType = BackendType.laptop;
        break;
      case BackendType.railway:
        _currentBackendUrl = railwayBackendUrl;
        _currentBackendType = BackendType.railway;
        break;
      case BackendType.aws:
        _currentBackendUrl = awsBackendUrl;
        _currentBackendType = BackendType.aws;
        break;
    }
  }
  
  /// Get backend status for all three backends
  static Future<BackendStatus> getBackendStatus() async {
    final laptopAvailable = await _checkBackendHealth(laptopBackendUrl);
    final railwayAvailable = await _checkBackendHealth(railwayBackendUrl);
    final awsAvailable = await _checkBackendHealth(awsBackendUrl);
    
    return BackendStatus(
      laptopAvailable: laptopAvailable,
      railwayAvailable: railwayAvailable,
      awsAvailable: awsAvailable,
      currentBackend: _currentBackendType,
    );
  }
}

enum BackendType {
  laptop,
  railway,
  aws,
}

class BackendStatus {
  final bool laptopAvailable;
  final bool railwayAvailable;
  final bool awsAvailable;
  final BackendType currentBackend;
  
  BackendStatus({
    required this.laptopAvailable,
    required this.railwayAvailable,
    required this.awsAvailable,
    required this.currentBackend,
  });
  
  String get statusMessage {
    if (laptopAvailable) {
      return '✅ Using Laptop (Fastest)';
    } else if (railwayAvailable) {
      return '🚂 Using Railway (Free Cloud)';
    } else if (awsAvailable) {
      return '☁️ Using AWS (Backup)';
    } else {
      return '❌ No backend available';
    }
  }
  
  String get detailedStatus {
    final available = <String>[];
    if (laptopAvailable) available.add('Laptop');
    if (railwayAvailable) available.add('Railway');
    if (awsAvailable) available.add('AWS');
    
    if (available.isEmpty) return 'All backends offline';
    return 'Available: ${available.join(', ')}';
  }
}
