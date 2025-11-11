import 'package:http/http.dart' as http;

/// Smart Backend Configuration with Triple Failover System
/// Priority 1: Laptop (192.168.31.39:3000) - Fastest, Free, Local
/// Priority 2: Railway (Cloud) - Free, NO COLD STARTS, Instant
/// Priority 3: Render (Cloud) - Backup, 50s Cold Start
class ApiConfig {
  // Backend URLs - Priority Order
  static const String laptopBackendUrl = 'http://192.168.31.39:3000/api';
  static const String awsBackendUrl = 'http://hazardnet-production.eba-74z3ihsf.us-east-1.elasticbeanstalk.com/api'; // AWS Elastic Beanstalk
  static const String railwayBackendUrl = 'https://hazardnet-production.up.railway.app'; // Railway backup
  
  // Current active backend - START WITH AWS (cloud, reliable)
  static String _currentBackendUrl = awsBackendUrl;
  static BackendType _currentBackendType = BackendType.aws;
  
  /// Get current backend URL
  static String get baseApiUrl => _currentBackendUrl;
  
  /// Get current backend type
  static BackendType get currentBackendType => _currentBackendType;
  
  /// Try to connect to backend with automatic triple failover
  static Future<String> getAvailableBackendUrl() async {
    print('🔍 [BACKEND] Starting backend connection check...');
    print('📱 [BACKEND] Device time: ${DateTime.now()}');
    
    // Priority 1: Try Laptop (fastest, free, local)
    print('🔌 [BACKEND] Testing Priority 1: Laptop ($laptopBackendUrl)');
    try {
      final startTime = DateTime.now();
      final laptopResponse = await _checkBackendHealth(laptopBackendUrl);
      final duration = DateTime.now().difference(startTime);
      
      if (laptopResponse) {
        _currentBackendUrl = laptopBackendUrl;
        _currentBackendType = BackendType.laptop;
        print('✅ [BACKEND] SUCCESS: Connected to Laptop Backend in ${duration.inMilliseconds}ms');
        print('🚀 [BACKEND] Using: $laptopBackendUrl');
        return laptopBackendUrl;
      } else {
        print('❌ [BACKEND] FAILED: Laptop backend returned non-200 status');
      }
    } catch (e) {
      print('⚠️ [BACKEND] ERROR: Laptop backend not available');
      print('📝 [BACKEND] Details: ${e.toString()}');
    }
    
    // Priority 2: Try AWS (cloud, reliable)
    print('☁️ [BACKEND] Testing Priority 2: AWS Cloud ($awsBackendUrl)');
    try {
      final startTime = DateTime.now();
      final awsResponse = await _checkBackendHealth(awsBackendUrl);
      final duration = DateTime.now().difference(startTime);
      
      if (awsResponse) {
        _currentBackendUrl = awsBackendUrl;
        _currentBackendType = BackendType.aws;
        print('✅ [BACKEND] SUCCESS: Connected to AWS Cloud in ${duration.inSeconds}s');
        print('🚀 [BACKEND] Using: $awsBackendUrl');
        return awsBackendUrl;
      } else {
        print('❌ [BACKEND] FAILED: AWS backend returned non-200 status');
      }
    } catch (e) {
      print('⚠️ [BACKEND] ERROR: AWS backend not available');
      print('📝 [BACKEND] Details: ${e.toString()}');
    }
    
    // Priority 3: Try Railway (backup cloud)
    print('☁️ [BACKEND] Testing Priority 3: Railway Backup ($railwayBackendUrl)');
    print('⏰ [BACKEND] Note: Railway may take up to 60 seconds if sleeping...');
    try {
      final startTime = DateTime.now();
      final railwayResponse = await _checkBackendHealth(railwayBackendUrl);
      final duration = DateTime.now().difference(startTime);
      
      if (railwayResponse) {
        _currentBackendUrl = railwayBackendUrl;
        _currentBackendType = BackendType.railway;
        print('✅ [BACKEND] SUCCESS: Connected to Railway Backup in ${duration.inSeconds}s');
        print('🚀 [BACKEND] Using: $railwayBackendUrl');
        return railwayBackendUrl;
      } else {
        print('❌ [BACKEND] FAILED: Railway backend returned non-200 status');
      }
    } catch (e) {
      print('⚠️ [BACKEND] ERROR: Railway backend not available');
      print('📝 [BACKEND] Details: ${e.toString()}');
    }
    
    // If all fail, default to laptop (will show error in app)
    _currentBackendUrl = laptopBackendUrl;
    _currentBackendType = BackendType.laptop;
    print('💥 [BACKEND] CRITICAL: All backends unavailable!');
    print('🔄 [BACKEND] Defaulting to laptop, user will see connection error');
    return laptopBackendUrl;
  }
  
  /// Check if backend is healthy
  static Future<bool> _checkBackendHealth(String baseUrl) async {
    try {
      final healthUrl = baseUrl.replaceAll('/api', '/health');
      // Longer timeout for cloud backends (Render takes 50s to wake from sleep)
      final timeout = baseUrl.contains('192.168') 
          ? const Duration(seconds: 3)  // Laptop: quick timeout
          : const Duration(seconds: 60); // Cloud: wait for cold start
      
      print('🏥 [HEALTH] Checking: $healthUrl');
      print('⏱️ [HEALTH] Timeout: ${timeout.inSeconds}s');
      
      final response = await http.get(
        Uri.parse(healthUrl),
      ).timeout(timeout);
      
      print('📡 [HEALTH] Response status: ${response.statusCode}');
      print('📦 [HEALTH] Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ [HEALTH] Backend is healthy!');
        return true;
      } else {
        print('⚠️ [HEALTH] Backend returned status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ [HEALTH] Health check failed: ${e.toString()}');
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
