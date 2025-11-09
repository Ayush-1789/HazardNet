import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:event_safety_app/core/constants/model_config.dart';

/// Detection result containing bounding box and class information
class Detection {
  final String label;
  final double confidence;
  final ui.Rect boundingBox; // Normalized coordinates (0.0 - 1.0)
  final int classIndex;

  Detection({
    required this.label,
    required this.confidence,
    required this.boundingBox,
    required this.classIndex,
  });

  @override
  String toString() {
    return 'Detection(label: $label, confidence: ${(confidence * 100).toStringAsFixed(1)}%, box: $boundingBox)';
  }
}

/// Service for TensorFlow Lite model inference
class TFLiteService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  bool _hasLoggedInputInfo = false;
  bool _hasLoggedImageFormat = false;
  bool _hasLoggedOutputInfo = false;
  bool _warnedClassCountMismatch = false;
  GpuDelegateV2? _gpuDelegate;
  int? _modelInputWidth;
  int? _modelInputHeight;
  int _inferenceCount = 0;

  /// Initialize the TFLite interpreter
  Future<void> loadModel() async {
    try {
      print('🔄 Loading model: ${ModelConfig.modelPath}');

      Interpreter? interpreter;

      if (ModelConfig.USE_GPU) {
        try {
          final gpuOptions = InterpreterOptions()
            ..threads = ModelConfig.NUM_THREADS;
          _gpuDelegate = GpuDelegateV2();
          gpuOptions.addDelegate(_gpuDelegate!);

          interpreter = await Interpreter.fromAsset(
            ModelConfig.modelPath,
            options: gpuOptions,
          );

          print('✅ GPU delegate enabled');
        } catch (e) {
          print('⚠️ GPU delegate unavailable, falling back: $e');
          _gpuDelegate?.delete();
          _gpuDelegate = null;
        }
      }

      if (interpreter == null) {
        final fallbackOptions = InterpreterOptions()
          ..threads = ModelConfig.NUM_THREADS;

        if (ModelConfig.USE_NNAPI) {
          fallbackOptions.useNnApiForAndroid = true;
          print('✅ NNAPI delegate enabled');
        } else if (ModelConfig.USE_GPU) {
          print('ℹ️ Falling back to CPU execution');
        } else {
          print('ℹ️ Using CPU execution');
        }

        interpreter = await Interpreter.fromAsset(
          ModelConfig.modelPath,
          options: fallbackOptions,
        );
      }

      _interpreter = interpreter;

      if (_interpreter == null) {
        throw Exception('Unable to create interpreter.');
      }

      // Validate model configuration
      if (!ModelConfig.validateConfig()) {
        print('⚠️ Model configuration validation failed');
      }

      final inputTensor = _interpreter!.getInputTensor(0);
      final inputShape = inputTensor.shape;
      if (inputShape.length >= 3) {
        // Typical TFLite layout: [1, height, width, channels]
        _modelInputHeight = inputShape[inputShape.length == 4 ? 1 : inputShape.length - 2];
        _modelInputWidth = inputShape[inputShape.length == 4 ? 2 : inputShape.length - 1];
      }

      final params = inputTensor.params;
      final outputTensor = _interpreter!.getOutputTensor(0);
      final outputShape = outputTensor.shape;

      _isModelLoaded = true;
      print('✅ Model loaded successfully');
      print('   Input shape: $inputShape');
      if (_modelInputWidth != null && _modelInputHeight != null) {
        print('   Derived input size -> width: $_modelInputWidth, height: $_modelInputHeight');
      }
      print('   Output shape: $outputShape');
      print('   Input type: ${inputTensor.type}');
      print('   Input quantization -> scale: ${params.scale}, zeroPoint: ${params.zeroPoint}');
    } catch (e) {
      print('❌ Error loading model: $e');
      _isModelLoaded = false;
      rethrow;
    }
  }

  /// Check if model is loaded
  bool get isModelLoaded => _isModelLoaded;

  /// Run inference on camera image
  Future<List<Detection>> detectObjects(CameraImage cameraImage, {bool? verboseOverride}) async {
    if (!_isModelLoaded || _interpreter == null) {
      print('⚠️ Model not loaded');
      return [];
    }

    try {
      final totalStopwatch = Stopwatch()..start();
      final preprocessStopwatch = Stopwatch()..start();
      final inputTensor = _preprocessCameraImage(cameraImage);
      preprocessStopwatch.stop();

      return _runDetection(
        inputTensor: inputTensor,
        preprocessStopwatch: preprocessStopwatch,
        totalStopwatch: totalStopwatch,
        verboseOverride: verboseOverride,
      );
    } catch (e) {
      print('❌ Error during inference: $e');
      return [];
    }
  }

  /// Run inference on a raw image byte buffer (e.g., JPEG from buffer)
  Future<List<Detection>> detectObjectsFromJpeg(
    Uint8List imageBytes, {
    bool verbose = false,
  }) async {
    if (!_isModelLoaded || _interpreter == null) {
      print('⚠️ Model not loaded');
      return [];
    }

    try {
      final totalStopwatch = Stopwatch()..start();
      final preprocessStopwatch = Stopwatch()..start();
      final img.Image? decoded = img.decodeImage(imageBytes);
      if (decoded == null) {
        preprocessStopwatch.stop();
        totalStopwatch.stop();
        print('⚠️ Failed to decode buffered image');
        return [];
      }

      final inputTensor = _preprocessRgbImage(decoded);
      preprocessStopwatch.stop();

      return _runDetection(
        inputTensor: inputTensor,
        preprocessStopwatch: preprocessStopwatch,
        totalStopwatch: totalStopwatch,
        verboseOverride: verbose,
      );
    } catch (e) {
      print('❌ Error during buffered inference: $e');
      return [];
    }
  }

  Future<List<Detection>> _runDetection({
    required dynamic inputTensor,
    required Stopwatch preprocessStopwatch,
    required Stopwatch totalStopwatch,
    bool? verboseOverride,
  }) async {
    final outputTensor = _interpreter!.getOutputTensor(0);
    final outputShape = outputTensor.shape;
    final bool verbose = verboseOverride ?? _shouldLogVerbose();

    if (verbose) {
      print('📊 Output shape: $outputShape');
    }

    final dynamic output = _createZeroFilledStructure(outputShape, outputTensor.type);

    final inferenceStopwatch = Stopwatch()..start();
    _interpreter!.run(inputTensor, output);
    inferenceStopwatch.stop();

    final postprocessStopwatch = Stopwatch()..start();
    final detections = _postProcessOutput(output, verbose);
    postprocessStopwatch.stop();
    totalStopwatch.stop();

    if (verbose) {
      print('⏱️ Timing breakdown:');
      print('   Preprocess: ${preprocessStopwatch.elapsedMilliseconds}ms');
      print('   Inference: ${inferenceStopwatch.elapsedMilliseconds}ms');
      print('   Postprocess: ${postprocessStopwatch.elapsedMilliseconds}ms');
      print('   Total: ${totalStopwatch.elapsedMilliseconds}ms');
    } else if (detections.isNotEmpty) {
      final top = detections.first;
      print('🎯 ${detections.length} detection(s) → ${top.label} ${(top.confidence * 100).toStringAsFixed(1)}%');
    }

    return detections;
  }

  /// Preprocess camera image for model input
  dynamic _preprocessCameraImage(CameraImage cameraImage) {
    final img.Image? rgbImage = _convertYUV420ToImageFast(cameraImage);
    if (rgbImage == null) {
      throw Exception('Failed to convert camera image');
    }
    return _preprocessRgbImage(rgbImage);
  }

  /// Preprocess generic RGB image for interpreter input
  dynamic _preprocessRgbImage(img.Image rgbImage) {
    final int targetWidth = _modelInputWidth ?? ModelConfig.inputWidth;
    final int targetHeight = _modelInputHeight ?? ModelConfig.inputHeight;

    final double sourceAspect = rgbImage.width / rgbImage.height;
    final double targetAspect = targetWidth / targetHeight;

    int scaledWidth;
    int scaledHeight;
    if (sourceAspect > targetAspect) {
      scaledWidth = targetWidth;
      scaledHeight = (targetWidth / sourceAspect).round();
    } else {
      scaledHeight = targetHeight;
      scaledWidth = (targetHeight * sourceAspect).round();
    }

    final img.Image scaledImage = img.copyResize(
      rgbImage,
      width: scaledWidth,
      height: scaledHeight,
      interpolation: img.Interpolation.linear,
    );

    final int offsetX = ((targetWidth - scaledWidth) / 2).floor();
    final int offsetY = ((targetHeight - scaledHeight) / 2).floor();

    final inputTensor = _interpreter!.getInputTensor(0);
    final params = inputTensor.params;
    final double scale = params.scale == 0 ? 1.0 : params.scale;
    final int zeroPoint = params.zeroPoint;
    final tensorType = inputTensor.type;
    final bool isInt8 = tensorType == TensorType.int8 || tensorType == TensorType.uint8;

    final int minValue = isInt8 ? -128 : 0;
    final int maxValue = isInt8 ? 127 : 255;

    if (!_hasLoggedInputInfo) {
      print('ℹ️ Preprocessing with quantization scale=$scale, zeroPoint=$zeroPoint, type=$tensorType');
      _hasLoggedInputInfo = true;
    }

    final Uint8List scaledRgb = scaledImage.getBytes(order: img.ChannelOrder.rgb);
    final Uint8List rgbBytes = Uint8List(targetWidth * targetHeight * 3);
    final int srcStride = scaledWidth * 3;
    final int dstStride = targetWidth * 3;

    for (int y = 0; y < scaledHeight; y++) {
      final int destRow = (y + offsetY) * dstStride + offsetX * 3;
      final int srcRow = y * srcStride;
      rgbBytes.setRange(destRow, destRow + srcStride, scaledRgb, srcRow);
    }

    if (isInt8) {
      final Int8List quantized = Int8List(rgbBytes.length);
      final double safeScale = scale == 0 ? 1.0 : scale;
      final double invScale = 1.0 / safeScale;
      for (int i = 0; i < rgbBytes.length; i++) {
        final double normalized = rgbBytes[i] / 255.0;
        final int quantizedValue = (normalized * invScale + zeroPoint)
            .round()
            .clamp(minValue, maxValue);
        quantized[i] = quantizedValue;
      }
      return _reshapeInt8Input(quantized, targetHeight, targetWidth);
    }

    final List<double> floatPixels = List<double>.filled(rgbBytes.length, 0.0);
    for (int i = 0; i < rgbBytes.length; i++) {
      floatPixels[i] = rgbBytes[i] / 255.0;
    }
    return _reshapeFloatInput(floatPixels, targetHeight, targetWidth);
  }

  /// Convert a [CameraImage] to JPEG bytes for storage or sharing.
  Uint8List? convertCameraImageToJpeg(
    CameraImage cameraImage, {
    int quality = AppConstants.imageQuality,
    bool forBuffering = false,
  }) {
    final img.Image? rgb = _convertYUV420ToImageFast(cameraImage);
    if (rgb == null) {
      return null;
    }
    img.Image processed = rgb;
    
    // For buffering, use much lower resolution to save CPU time
    final int maxWidth = forBuffering ? 480 : AppConstants.maxImageWidth;
    final int maxHeight = forBuffering ? 360 : AppConstants.maxImageHeight;
    final int jpegQuality = forBuffering ? 40 : quality;
    
    final bool exceedsWidth = rgb.width > maxWidth;
    final bool exceedsHeight = rgb.height > maxHeight;
    if (exceedsWidth || exceedsHeight) {
      final double widthScale = maxWidth / rgb.width;
      final double heightScale = maxHeight / rgb.height;
      final double scale = math.min(1.0, math.min(widthScale, heightScale));
      final int targetWidth = (rgb.width * scale).round().clamp(1, maxWidth);
      final int targetHeight = (rgb.height * scale).round().clamp(1, maxHeight);
      processed = img.copyResize(
        rgb,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.linear,
      );
    }
    return Uint8List.fromList(img.encodeJpg(processed, quality: jpegQuality));
  }

  /// Convert CameraImage to img.Image with support for multiple formats
  img.Image? _convertYUV420ToImageFast(CameraImage cameraImage) {
    try {
      final int width = cameraImage.width;
      final int height = cameraImage.height;
      final int planesCount = cameraImage.planes.length;
      
      if (!_hasLoggedImageFormat) {
        print('📸 Camera image: ${width}x${height}, planes: $planesCount');
      }
      
      // Handle BGRA format (1 plane) - Common with CameraX on Android
      if (planesCount == 1) {
        if (!_hasLoggedImageFormat) {
          print('   Processing BGRA format (1 plane)');
          _hasLoggedImageFormat = true;
        }
        return _convertBGRAToImage(cameraImage);
      }
      
      // Handle YUV420 format (3 planes)
      if (planesCount >= 3) {
        if (!_hasLoggedImageFormat) {
          print('   Processing YUV420 format (3 planes)');
          _hasLoggedImageFormat = true;
        }
        return _convertYUV420Planes(cameraImage);
      }
      
      print('❌ Unsupported camera format: $planesCount planes');
      return null;
    } catch (e) {
      print('❌ Error converting camera image: $e');
      return null;
    }
  }
  
  /// Convert BGRA format (1 plane) to img.Image
  img.Image? _convertBGRAToImage(CameraImage cameraImage) {
    try {
      final int width = cameraImage.width;
      final int height = cameraImage.height;
      final bytes = cameraImage.planes[0].bytes;
      final int bytesPerPixel = cameraImage.planes[0].bytesPerPixel ?? 4;
      final int bytesPerRow = cameraImage.planes[0].bytesPerRow;
      
      final image = img.Image(width: width, height: height);
      
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          final int pixelIndex = h * bytesPerRow + w * bytesPerPixel;
          
          if (pixelIndex + 3 < bytes.length) {
            // BGRA format: B, G, R, A
            final b = bytes[pixelIndex];
            final g = bytes[pixelIndex + 1];
            final r = bytes[pixelIndex + 2];
            
            image.setPixelRgb(w, h, r, g, b);
          }
        }
      }
      
      return image;
    } catch (e) {
      print('❌ Error converting BGRA: $e');
      return null;
    }
  }
  
  /// Convert YUV420 format (3 planes) to img.Image - OPTIMIZED for speed
  img.Image? _convertYUV420Planes(CameraImage cameraImage) {
    try {
      final int width = cameraImage.width;
      final int height = cameraImage.height;
      
      // Validate we have at least 3 planes
      if (cameraImage.planes.length < 3) {
        print('❌ Invalid YUV image: need at least 3 planes, got ${cameraImage.planes.length}');
        return null;
      }
      
      final yPlane = cameraImage.planes[0];
      final uPlane = cameraImage.planes[1];
      final vPlane = cameraImage.planes[2];
      
      final yBytes = yPlane.bytes;
      final uBytes = uPlane.bytes;
      final vBytes = vPlane.bytes;
      
      // Validate plane sizes
      if (yBytes.isEmpty || uBytes.isEmpty || vBytes.isEmpty) {
        print('❌ Invalid camera image: empty plane data');
        return null;
      }
      
      final image = img.Image(width: width, height: height);
      
      final int yRowStride = yPlane.bytesPerRow;
      final int uvRowStride = uPlane.bytesPerRow;
      final int uvPixelStride = uPlane.bytesPerPixel ?? 1;

      // Optimized loop - process 2x2 blocks to reduce UV lookups
      for (int h = 0; h < height; h += 2) {
        for (int w = 0; w < width; w += 2) {
          final uvRow = h ~/ 2;
          final uvCol = w ~/ 2;
          final uvIndex = uvRow * uvRowStride + uvCol * uvPixelStride;
          
          // Bounds check for UV planes (once per 2x2 block)
          if (uvIndex >= uBytes.length || uvIndex >= vBytes.length) continue;
          
          final int uValue = uBytes[uvIndex];
          final int vValue = vBytes[uvIndex];
          
          // Precompute color components (shared by 2x2 block)
          final double vFactor = 1.402 * (vValue - 128);
          final double uFactor = 1.772 * (uValue - 128);
          final double uvFactor = 0.344136 * (uValue - 128) + 0.714136 * (vValue - 128);
          
          // Process 2x2 block
          for (int dh = 0; dh < 2 && (h + dh) < height; dh++) {
            for (int dw = 0; dw < 2 && (w + dw) < width; dw++) {
              final yIndex = (h + dh) * yRowStride + (w + dw);
              if (yIndex >= yBytes.length) continue;
              
              final int yValue = yBytes[yIndex];
              
              // YUV to RGB conversion
              final int r = (yValue + vFactor).round().clamp(0, 255);
              final int g = (yValue - uvFactor).round().clamp(0, 255);
              final int b = (yValue + uFactor).round().clamp(0, 255);

              image.setPixelRgb(w + dw, h + dh, r, g, b);
            }
          }
        }
      }

      return image;
    } catch (e) {
      print('❌ Error converting YUV420: $e');
      return null;
    }
  }

  /// Post-process model output to extract detections
  List<Detection> _postProcessOutput(List output, bool verbose) {
    final List<Detection> detections = [];

    if (output.isEmpty) return detections;

    try {
      // Debug: Print output structure
      if (verbose) {
        print('📦 Raw output structure: ${output.runtimeType}, length=${output.length}');
      }

      final dynamic batch = output[0];

      // Get output tensor quantization info (if available)
      final outTensor = _interpreter!.getOutputTensor(0);
      final outParams = outTensor.params;
      final double outScale = outParams.scale == 0 ? 1.0 : outParams.scale;
      final int outZeroPoint = outParams.zeroPoint;
      final TensorType outType = outTensor.type;
      final List<int> outShape = outTensor.shape;
      if (!_hasLoggedOutputInfo) {
        print('ℹ️ Output tensor shape: $outShape, type=$outType, scale=$outScale, zeroPoint=$outZeroPoint');
        _hasLoggedOutputInfo = true;
      }

      final int inputWidthRef = _modelInputWidth ?? ModelConfig.inputWidth;
      final int inputHeightRef = _modelInputHeight ?? ModelConfig.inputHeight;

      // Normalize predictions into List<List<double>> where each inner list is a prediction [x,y,w,h,...]
      final List<List<double>> preds = [];

      if (batch is List && batch.isNotEmpty && batch[0] is List) {
        // Try to infer layout from output tensor shape when possible
        try {
          if (outShape.length == 3) {
            final int c = outShape[1];
            final int n = outShape[2];
            // If batch is [C, N] (common for some YOLO exports)
            if (batch.length == c && (batch[0] as List).length == n) {
              for (int i = 0; i < n; i++) preds.add(List.filled(c, 0.0));
              for (int ci = 0; ci < c; ci++) {
                final row = batch[ci] as List;
                for (int ni = 0; ni < n; ni++) {
                  final raw = row[ni];
                  double val = 0.0;
                  if (raw is num) {
                    if (outType == TensorType.int8 || outType == TensorType.uint8) {
                      val = (raw.toDouble() - outZeroPoint) * outScale;
                    } else {
                      val = raw.toDouble();
                    }
                  } else {
                    val = double.tryParse(raw.toString()) ?? 0.0;
                  }
                  preds[ni][ci] = val;
                }
              }
            } else if (batch.length == n && (batch[0] as List).length == c) {
              // Already [N, C]
              for (final p in batch) {
                if (p is List) {
                  preds.add(p.map((e) => e is num ? (outType == TensorType.int8 || outType == TensorType.uint8 ? (e.toDouble() - outZeroPoint) * outScale : e.toDouble()) : double.tryParse(e.toString()) ?? 0.0).toList());
                }
              }
            } else {
              // Fallback generic handling
              for (final p in batch) {
                if (p is List) preds.add(p.map((e) => e is num ? (outType == TensorType.int8 || outType == TensorType.uint8 ? (e.toDouble() - outZeroPoint) * outScale : e.toDouble()) : double.tryParse(e.toString()) ?? 0.0).toList());
              }
            }
          } else {
            // Unknown dimensionality - fallback to generic
            for (final p in batch) {
              if (p is List) preds.add(p.map((e) => e is num ? (outType == TensorType.int8 || outType == TensorType.uint8 ? (e.toDouble() - outZeroPoint) * outScale : e.toDouble()) : double.tryParse(e.toString()) ?? 0.0).toList());
            }
          }
        } catch (e) {
          // Safe fallback
          for (final p in batch) {
            if (p is List) preds.add(p.map((e) => e is num ? (outType == TensorType.int8 || outType == TensorType.uint8 ? (e.toDouble() - outZeroPoint) * outScale : e.toDouble()) : double.tryParse(e.toString()) ?? 0.0).toList());
          }
        }
      } else if (batch is List) {
        for (final p in batch) {
          if (p is List) preds.add(p.map((e) => e is num ? (outType == TensorType.int8 || outType == TensorType.uint8 ? (e.toDouble() - outZeroPoint) * outScale : e.toDouble()) : double.tryParse(e.toString()) ?? 0.0).toList());
        }
      }

      // Debug preview
      final preview = preds.take(3).toList();
      if (verbose && preview.isNotEmpty) {
        print('ℹ️ Preview of first ${preview.length} predictions:');
        for (int i = 0; i < preview.length; i++) {
          final p = preview[i];
          print('   #$i -> ${p.take(8).map((e) => e.toStringAsFixed(4)).toList()}');
        }
      }

      // Interpret each prediction. Many YOLO-style heads output:
      // [x, y, w, h, objectness, class0, class1, ...]
      // We treat remaining elements after the first 5 as class logits/probabilities.
      const int coordCount = 4;
      for (final prediction in preds) {
        if (prediction.length <= coordCount) continue;

        double xCenter = prediction[0];
        double yCenter = prediction[1];
        double width = prediction[2];
        double height = prediction[3];

        // Determine if coordinates are normalized (0..1) or pixel-space (>1)
        final bool coordsNormalized =
            (xCenter <= 1.0 && yCenter <= 1.0 && width <= 1.0 && height <= 1.0);

        final int availableLength = prediction.length;
        final double objectnessRaw = availableLength > coordCount ? prediction[coordCount] : -10.0;
        final double objectnessProb = _sigmoid(objectnessRaw).clamp(0.0, 1.0);

        final int classValuesAvailable = math.max(0, availableLength - (coordCount + 1));
        final int configuredLabels = ModelConfig.LABELS.length;
        final int classesToUse = classValuesAvailable == 0
            ? 0
            : math.min(classValuesAvailable, configuredLabels);

        if (!_warnedClassCountMismatch && classValuesAvailable > 0 && classValuesAvailable != configuredLabels) {
          print('⚠️ Model outputs $classValuesAvailable class scores but ${ModelConfig.LABELS.length} labels are configured. Using $classesToUse of them.');
          _warnedClassCountMismatch = true;
        }

        double bestClassProb = classValuesAvailable == 0 ? 1.0 : 0.0;
        int bestClass = 0;

        if (classesToUse > 0) {
          for (int ci = 0; ci < classesToUse; ci++) {
            final double rawCls = prediction[coordCount + 1 + ci];
            double clsProb;

            if (rawCls >= 0.0 && rawCls <= 1.0) {
              clsProb = rawCls;
            } else {
              clsProb = _sigmoid(rawCls);
            }

            if (clsProb > bestClassProb) {
              bestClassProb = clsProb;
              bestClass = ci;
            }
          }
        }

        final double confidence = (objectnessProb * bestClassProb).clamp(0.0, 1.0);

        // Apply filtering thresholds
        if (confidence < ModelConfig.CONFIDENCE_THRESHOLD) continue;
        if (width <= 0.001 || height <= 0.001) continue;

        // Normalize coordinates into 0..1 range for UI
        final double normX = coordsNormalized ? xCenter : (xCenter / inputWidthRef);
        final double normY = coordsNormalized ? yCenter : (yCenter / inputHeightRef);
        final double normW = coordsNormalized ? width : (width / inputWidthRef);
        final double normH = coordsNormalized ? height : (height / inputHeightRef);

        final double left = (normX - normW / 2).clamp(0.0, 1.0);
        final double top = (normY - normH / 2).clamp(0.0, 1.0);
        final double right = (normX + normW / 2).clamp(0.0, 1.0);
        final double bottom = (normY + normH / 2).clamp(0.0, 1.0);

        final double boxWidth = right - left;
        final double boxHeight = bottom - top;
        if (boxWidth <= 0.01 || boxHeight <= 0.01) continue;

        final int labelIndex = bestClass;

        detections.add(Detection(
          label: ModelConfig.getLabelForIndex(labelIndex),
          confidence: confidence,
          boundingBox: ui.Rect.fromLTRB(left, top, right, bottom),
          classIndex: labelIndex,
        ));
      }

      // NMS and limit
      var result = _nonMaxSuppression(detections);
      if (result.length > ModelConfig.MAX_DETECTIONS) result = result.sublist(0, ModelConfig.MAX_DETECTIONS);

      if (verbose && result.isNotEmpty) {
        print('🎯 Found ${result.length} detections');
        for (final d in result) print('   $d');
      }

      return result;
    } catch (e) {
      print('❌ Error in post-processing: $e');
      return detections;
    }
  }

  List<dynamic> _reshapeInt8Input(Int8List quantized, int height, int width) {
    int index = 0;
    return [
      List.generate(height, (_) {
        return List.generate(width, (_) {
          final int r = quantized[index++];
          final int g = quantized[index++];
          final int b = quantized[index++];
          return <int>[r, g, b];
        }, growable: false);
      }, growable: false),
    ];
  }

  List<dynamic> _reshapeFloatInput(List<double> pixels, int height, int width) {
    int index = 0;
    return [
      List.generate(height, (_) {
        return List.generate(width, (_) {
          final double r = pixels[index++];
          final double g = pixels[index++];
          final double b = pixels[index++];
          return <double>[r, g, b];
        }, growable: false);
      }, growable: false),
    ];
  }

  /// Build a zero-filled nested list matching [shape] and tensor [type].
  dynamic _createZeroFilledStructure(List<int> shape, TensorType type) {
    final bool useInt = type == TensorType.int8 || type == TensorType.uint8;
    if (shape.isEmpty) {
      return useInt ? 0 : 0.0;
    }
    if (shape.length == 1) {
      return List.filled(shape[0], useInt ? 0 : 0.0, growable: false);
    }
    return List.generate(
      shape[0],
      (_) => _createZeroFilledStructure(shape.sublist(1), type),
      growable: false,
    );
  }

  bool _shouldLogVerbose() {
    _inferenceCount++;
    return _inferenceCount <= 5 || _inferenceCount % 20 == 0;
  }

  double _sigmoid(double x) => 1.0 / (1.0 + math.exp(-x));

  /// Non-Maximum Suppression to remove overlapping boxes
  List<Detection> _nonMaxSuppression(List<Detection> detections) {
    if (detections.isEmpty) return [];

    // Sort by confidence (highest first)
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));

    List<Detection> result = [];
    List<bool> suppressed = List.filled(detections.length, false);

    for (int i = 0; i < detections.length; i++) {
      if (suppressed[i]) continue;

      result.add(detections[i]);

      for (int j = i + 1; j < detections.length; j++) {
        if (suppressed[j]) continue;

        // Calculate IoU
        final iou = _calculateIoU(
          detections[i].boundingBox,
          detections[j].boundingBox,
        );

        // Suppress if IoU is above threshold and same class
        if (iou > ModelConfig.IOU_THRESHOLD &&
            detections[i].classIndex == detections[j].classIndex) {
          suppressed[j] = true;
        }
      }
    }

    return result;
  }

  /// Calculate Intersection over Union for two bounding boxes
  double _calculateIoU(ui.Rect box1, ui.Rect box2) {
    final intersection = box1.intersect(box2);
    if (intersection.isEmpty) return 0.0;

    final intersectionArea = intersection.width * intersection.height;
    final box1Area = box1.width * box1.height;
    final box2Area = box2.width * box2.height;
    final unionArea = box1Area + box2Area - intersectionArea;

    return intersectionArea / unionArea;
  }

  /// Draw bounding boxes on a JPEG image for visualization
  Uint8List? drawDetectionsOnJpeg(
    Uint8List jpegBytes,
    List<Detection> detections, {
    int strokeWidth = 4,
  }) {
    try {
      final img.Image? decoded = img.decodeImage(jpegBytes);
      if (decoded == null) return null;
      
      final int width = decoded.width;
      final int height = decoded.height;
      
      for (final detection in detections) {
        final box = detection.boundingBox;
        
        // Convert normalized coordinates to pixel coordinates
        final int x1 = (box.left * width).round().clamp(0, width - 1);
        final int y1 = (box.top * height).round().clamp(0, height - 1);
        final int x2 = (box.right * width).round().clamp(0, width - 1);
        final int y2 = (box.bottom * height).round().clamp(0, height - 1);
        
        // Get color for this class
        final colorValue = ModelConfig.getColorForClass(detection.label);
        final color = img.ColorRgb8(
          (colorValue >> 16) & 0xFF,
          (colorValue >> 8) & 0xFF,
          colorValue & 0xFF,
        );
        
        // Draw rectangle
        img.drawRect(
          decoded,
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
          color: color,
          thickness: strokeWidth,
        );
        
        // Draw label background and text
        final label = '${detection.label} ${(detection.confidence * 100).toStringAsFixed(1)}%';
        final textY = (y1 - 20).clamp(0, height - 20);
        
        // Draw semi-transparent background for text
        img.fillRect(
          decoded,
          x1: x1,
          y1: textY,
          x2: (x1 + label.length * 8).clamp(0, width),
          y2: textY + 16,
          color: img.ColorRgb8(0, 0, 0),
        );
        
        // Draw text
        img.drawString(
          decoded,
          label,
          font: img.arial14,
          x: x1 + 2,
          y: textY + 2,
          color: color,
        );
      }
      
      return Uint8List.fromList(img.encodeJpg(decoded, quality: AppConstants.imageQuality));
    } catch (e) {
      print('❌ Error drawing detections: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    // GpuDelegateV2 exposes `delete()` to free native resources.
    _gpuDelegate?.delete();
    _gpuDelegate = null;
    _isModelLoaded = false;
    _hasLoggedInputInfo = false;
    _hasLoggedImageFormat = false;
    _hasLoggedOutputInfo = false;
    _warnedClassCountMismatch = false;
    _modelInputWidth = null;
    _modelInputHeight = null;
    _inferenceCount = 0;
    print('🗑️ TFLite service disposed');
  }
}
