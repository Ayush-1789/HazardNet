# 🤖 ML Model Integration Guide

## ✅ What's Integrated

Your TFLite hazard detection model is now fully integrated with the camera! Here's what was added:

### 1. **Model Configuration** (`lib/core/constants/model_config.dart`)
- ✅ Single file to manage all model settings
- ✅ Easy model swapping - just change `MODEL_FILENAME` constant
- ✅ Configurable input size, confidence threshold, IoU threshold
- ✅ Class labels and color mappings

### 2. **TFLite Service** (`lib/data/services/tflite_service.dart`)
- ✅ Loads TFLite model from assets
- ✅ Converts camera frames (YUV420) to RGB
- ✅ Preprocesses images for model input
- ✅ Runs inference on each frame
- ✅ Post-processes output with Non-Maximum Suppression
- ✅ Returns bounding boxes with confidence scores

### 3. **Camera Integration**
- ✅ Updated `CameraBloc` to use TFLite service
- ✅ Real-time inference on camera frames
- ✅ Detections stored in camera state
- ✅ Automatic cleanup on disposal

### 4. **Visual Overlay** (`lib/widgets/bounding_box_overlay.dart`)
- ✅ Draws colored bounding boxes around detected hazards
- ✅ Shows labels with confidence scores
- ✅ Corner indicators for better visibility
- ✅ Color-coded by hazard type

### 5. **Updated Camera Screen**
- ✅ Shows detections count in stats
- ✅ Real-time bounding box overlay
- ✅ FPS counter for performance monitoring

---

## 🔄 How to Swap Models

### Quick Model Change (3 Easy Steps):

1. **Place your new model** in the `models/` folder
   ```
   models/
   ├── hazard_int8_640.tflite    # Current model
   └── your_new_model.tflite      # Your new model
   ```

2. **Update the model filename** in `lib/core/constants/model_config.dart`:
   ```dart
   // Change this line:
   static const String MODEL_FILENAME = 'your_new_model.tflite';
   ```

3. **Update model parameters** (if needed):
   ```dart
   // Input dimensions
   static const int INPUT_WIDTH = 640;   // Change if your model uses different size
   static const int INPUT_HEIGHT = 640;
   
   // Number of classes
   static const int NUM_CLASSES = 5;     // Update based on your model
   
   // Class labels
   static const List<String> LABELS = [
     'pothole',
     'speed_breaker',
     'obstacle',
     'closed_road',
     'lane_blockage',
   ];
   
   // Detection thresholds
   static const double CONFIDENCE_THRESHOLD = 0.5;  // Adjust as needed
   static const double IOU_THRESHOLD = 0.45;
   ```

That's it! Hot reload the app and your new model is active! 🎉

---

## 🎨 Customization Options

### Change Detection Box Colors

Edit `CLASS_COLORS` in `model_config.dart`:
```dart
static const Map<String, int> CLASS_COLORS = {
  'pothole': 0xFFFF5252,         // Red
  'speed_breaker': 0xFFFFD740,   // Yellow
  'obstacle': 0xFFFF9800,        // Orange
  'closed_road': 0xFFF44336,     // Deep Red
  'lane_blockage': 0xFFFF6E40,   // Deep Orange
};
```

### Adjust Performance

In `model_config.dart`:
```dart
// Reduce threads for better battery life
static const int NUM_THREADS = 2;  // Default: 4

// Enable GPU acceleration (experimental)
static const bool USE_GPU = true;   // Default: false

// Adjust confidence threshold
static const double CONFIDENCE_THRESHOLD = 0.6;  // Higher = fewer false positives
```

### Change Max Detections

```dart
static const int MAX_DETECTIONS = 15;  // Default: 10
```

---

## 📊 Model Output Format

Your model should output in **YOLOv8 format**:
- Shape: `[1, num_predictions, num_classes + 4]`
- First 4 values: `[x_center, y_center, width, height]` (normalized 0-1)
- Remaining values: Class confidence scores

Example for 5 classes:
```
[1, 8400, 9]
       ↑    ↑
       |    └── 4 bbox coords + 5 class scores
       └── Number of prediction anchors
```

---

## 🔧 Troubleshooting

### Model Not Loading
- ✅ Check `models/` folder contains your `.tflite` file
- ✅ Verify filename matches `MODEL_FILENAME` in `model_config.dart`
- ✅ Check terminal for error messages
- ✅ Ensure model is in TFLite format (not .pb or .onnx)

### No Detections Appearing
- ✅ Lower `CONFIDENCE_THRESHOLD` (try 0.3 or 0.4)
- ✅ Check if model is trained on similar classes
- ✅ Verify `INPUT_WIDTH` and `INPUT_HEIGHT` match your model
- ✅ Check terminal logs for detection count

### Low FPS
- ✅ Reduce `INPUT_WIDTH/HEIGHT` (try 320x320)
- ✅ Decrease `NUM_THREADS` if phone gets hot
- ✅ Enable `USE_NNAPI` on Android for hardware acceleration
- ✅ Use quantized (INT8) models instead of FP32

### Wrong Box Positions
- ✅ Verify model outputs normalized coordinates (0.0 - 1.0)
- ✅ Check output format matches YOLOv8 structure
- ✅ Review preprocessing in `TFLiteService._preprocessImage()`

---

## 📱 Testing Your Model

1. **Run the app**: `flutter run`
2. **Go to Camera tab** (bottom navigation)
3. **Tap the green scan button** to start detection
4. **Point camera at road hazards**
5. **Watch for colored boxes** appearing over detected hazards
6. **Check stats** at bottom for:
   - Detections count
   - FPS (frames per second)
   - Total frames processed

---

## 🚀 Performance Tips

1. **Use INT8 quantized models** (faster inference)
2. **Lower resolution** for real-time performance
3. **Batch processing** if FPS is too high (skip every N frames)
4. **Profile your model** using Android Profiler
5. **Test on actual device** (not emulator)

---

## 📂 File Structure

```
lib/
├── core/
│   └── constants/
│       └── model_config.dart        # 🔧 Edit here to change models
├── data/
│   └── services/
│       └── tflite_service.dart      # Model inference logic
├── widgets/
│   └── bounding_box_overlay.dart    # Detection visualization
├── bloc/
│   └── camera/
│       ├── camera_bloc.dart         # Uses TFLite service
│       └── camera_state.dart        # Stores detections
└── screens/
    └── camera/
        └── camera_screen.dart       # Shows bounding boxes

models/
└── hazard_int8_640.tflite          # Your model file
```

---

## 🎯 Next Steps

1. **Test different confidence thresholds** to find optimal accuracy
2. **Collect real-world images** to improve model
3. **Train custom model** with your own dataset
4. **Add model analytics** (track detection accuracy)
5. **Implement model versioning** for A/B testing

---

## 📝 Example: Using a Different Model

Let's say you have a new model `road_hazard_v2.tflite` with 3 classes:

**Step 1**: Place in `models/` folder
```
models/
├── hazard_int8_640.tflite
└── road_hazard_v2.tflite     # New model
```

**Step 2**: Edit `lib/core/constants/model_config.dart`:
```dart
// Change filename
static const String MODEL_FILENAME = 'road_hazard_v2.tflite';

// Update classes
static const int NUM_CLASSES = 3;

// Update labels
static const List<String> LABELS = [
  'pothole',
  'crack',
  'debris',
];

// Add colors for new classes
static const Map<String, int> CLASS_COLORS = {
  'pothole': 0xFFFF5252,
  'crack': 0xFFFFEB3B,
  'debris': 0xFF9C27B0,
};
```

**Step 3**: Hot reload! ✨

---

Happy detecting! 🚗💨

For questions or issues, check the terminal logs for detailed error messages.
