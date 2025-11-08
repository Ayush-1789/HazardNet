/// Configuration for TFLite models
/// Change MODEL_FILENAME to switch models easily - just update this constant
/// and place your new model in the models/ folder
class ModelConfig {
  // ============================================
  // 🔧 CHANGE THIS TO SWAP MODELS
  // ============================================
  // unified_hazards_int8.tflite was detecting potholes at 36.9% with 70ms inference
  static const String MODEL_FILENAME = 'unified_hazards_int8.tflite';
  
  // ============================================
  // Model path (automatically constructed)
  // ============================================
  static const String MODEL_PATH = 'models/$MODEL_FILENAME';
  
  // ============================================
  // Model Input/Output Configuration
  // Adjust these based on your model's requirements
  // ============================================
  
  // Input image dimensions (YOLOv8 typically uses 640x640)
  // ⚠️ MUST MATCH YOUR MODEL'S ACTUAL INPUT SIZE!
  // unified_hazards_int8.tflite: 256x256 input
  static const int INPUT_WIDTH = 256;
  static const int INPUT_HEIGHT = 256;
  
  // Number of detection classes
  // Can't use `const` with `.length` in a compile-time constant expression on
  // some Dart versions/analysers, so make this a runtime final instead.
  static final int NUM_CLASSES = LABELS.length; // Multi-class model
  
  // Confidence threshold for detections
  static const double CONFIDENCE_THRESHOLD = 0.25; // Lower for testing new models
  
  // IoU threshold for Non-Maximum Suppression
  static const double IOU_THRESHOLD = 0.4;
  
  // Maximum number of detections to return
  static const int MAX_DETECTIONS = 10;
  
  // Frame skipping for better FPS (buffer every Nth frame)
  static const int FRAME_SKIP = 1; // Buffer every frame to maintain high temporal coverage

  // Lightweight pre-buffering cadence (store every Nth skipped frame)
  static const int PREBUFFER_EVERY_N = 0; // Disable pre-buffering to reduce overhead
  
  // Buffer configuration for gyro-triggered analysis
  static const int BUFFER_DURATION_SECONDS = 10; // Maintain 10s of frames in memory
  static const int BUFFER_MAX_FRAMES = 300; // Roughly 30 FPS * 10 seconds
  static const int GYRO_ANALYSIS_MAX_FRAMES = 90; // Analyze at most 90 frames per trigger
  static const double GYRO_MIN_CONFIDENCE = 0.35; // Minimum confidence to persist hazard
  
  // ============================================
  // Class Labels
  // Update these to match your model's classes
  // ============================================
  static const List<String> LABELS = [
    'pothole',
    'speed_breaker',
    'obstacle',
    'closed_road',
    'lane_blockage',
  ];
  
  // ============================================
  // Detection Box Colors (for visualization)
  // ============================================
  static const Map<String, int> CLASS_COLORS = {
    'pothole': 0xFFFF5252, // Red
    'speed_breaker': 0xFFFFD740, // Yellow
    'obstacle': 0xFFFF9800, // Orange
    'closed_road': 0xFFF44336, // Deep Red
    'lane_blockage': 0xFFFF6E40, // Deep Orange
  };
  
  // ============================================
  // Performance Settings
  // ============================================
  
  // Number of threads for inference
  static const int NUM_THREADS = 4;
  
  // Use GPU delegate if available (experimental)
  static const bool USE_GPU = false; // Float models may work better with NNAPI
  
  // Use NNAPI delegate on Android (experimental)
  static const bool USE_NNAPI = false; // NNAPI actually SLOWS DOWN this model (427ms vs 70ms)
  
  // ============================================
  // Helper Methods
  // ============================================
  
  /// Get color for a specific class label
  static int getColorForClass(String label) {
    return CLASS_COLORS[label] ?? 0xFF9E9E9E; // Default gray
  }
  
  /// Get label for class index
  static String getLabelForIndex(int index) {
    if (index >= 0 && index < LABELS.length) {
      return LABELS[index];
    }
    return 'unknown';
  }
  
  /// Validate model configuration
  static bool validateConfig() {
    if (LABELS.length != NUM_CLASSES) {
      print('Warning: Number of labels (${LABELS.length}) does not match NUM_CLASSES ($NUM_CLASSES)');
      return false;
    }
    return true;
  }
}
