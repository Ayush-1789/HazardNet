import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:event_safety_app/data/services/tflite_service.dart';

/// Service for annotating images with bounding boxes and labels
class ImageAnnotationService {
  /// Draw bounding boxes on an image and save it
  /// 
  /// [imagePath] - Path to the original image
  /// [detections] - List of detections to draw
  /// [imageWidth] - Original image width
  /// [imageHeight] - Original image height
  /// 
  /// Returns the path to the annotated image
  static Future<String> annotateAndSaveImage({
    required String imagePath,
    required List<Detection> detections,
    required int imageWidth,
    required int imageHeight,
  }) async {
    try {
      // Read the original image
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      
      // Decode image using image package
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Draw bounding boxes and labels on the image
      for (final detection in detections) {
        // Convert normalized coordinates to pixel coordinates
        final left = (detection.boundingBox.left * image.width).toInt();
        final top = (detection.boundingBox.top * image.height).toInt();
        final right = (detection.boundingBox.right * image.width).toInt();
        final bottom = (detection.boundingBox.bottom * image.height).toInt();

        // Choose color based on hazard type
        img.Color boxColor;
        switch (detection.label.toLowerCase()) {
          case 'pothole':
            boxColor = img.ColorRgb8(255, 87, 34); // Deep Orange
            break;
          case 'speed_breaker':
          case 'speed_breaker_unmarked':
            boxColor = img.ColorRgb8(255, 193, 7); // Amber
            break;
          case 'obstacle':
            boxColor = img.ColorRgb8(244, 67, 54); // Red
            break;
          default:
            boxColor = img.ColorRgb8(33, 150, 243); // Blue
        }

        // Draw bounding box (thicker lines for visibility)
        final thickness = 4;
        
        // Top line
        img.drawRect(
          image,
          x1: left,
          y1: top,
          x2: right,
          y2: top + thickness,
          color: boxColor,
        );
        
        // Bottom line
        img.drawRect(
          image,
          x1: left,
          y1: bottom - thickness,
          x2: right,
          y2: bottom,
          color: boxColor,
        );
        
        // Left line
        img.drawRect(
          image,
          x1: left,
          y1: top,
          x2: left + thickness,
          y2: bottom,
          color: boxColor,
        );
        
        // Right line
        img.drawRect(
          image,
          x1: right - thickness,
          y1: top,
          x2: right,
          y2: bottom,
          color: boxColor,
        );

        // Draw label background
        final label = '${detection.label} ${(detection.confidence * 100).toStringAsFixed(1)}%';
        final labelHeight = 30;
        final labelWidth = label.length * 12; // Approximate width
        
        // Draw semi-transparent background for label
        img.drawRect(
          image,
          x1: left,
          y1: top - labelHeight,
          x2: left + labelWidth,
          y2: top,
          color: boxColor,
        );

        // Draw label text (white color)
        img.drawString(
          image,
          label,
          font: img.arial24,
          x: left + 5,
          y: top - labelHeight + 5,
          color: img.ColorRgb8(255, 255, 255),
        );
      }

      // Encode the annotated image to JPEG
      final annotatedBytes = img.encodeJpg(image, quality: 90);

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final directory = await getApplicationDocumentsDirectory();
      final annotatedPath = '${directory.path}/annotated_$timestamp.jpg';
      
      // Save the annotated image
      final annotatedFile = File(annotatedPath);
      await annotatedFile.writeAsBytes(annotatedBytes);

      debugPrint('✅ Annotated image saved: $annotatedPath');
      return annotatedPath;
    } catch (e) {
      debugPrint('❌ Failed to annotate image: $e');
      rethrow;
    }
  }

  /// Draw bounding boxes on a camera image and save it
  /// 
  /// [cameraImage] - Camera image from camera stream
  /// [detections] - List of detections to draw
  /// 
  /// Returns the path to the annotated image
  static Future<String> annotateAndSaveCameraImage({
    required ui.Image cameraImage,
    required List<Detection> detections,
  }) async {
    try {
      // Convert ui.Image to bytes
      final byteData = await cameraImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert camera image to bytes');
      }

      // Decode using image package
      img.Image? image = img.decodePng(byteData.buffer.asUint8List());
      if (image == null) {
        throw Exception('Failed to decode camera image');
      }

      // Draw bounding boxes (same logic as above)
      for (final detection in detections) {
        final left = (detection.boundingBox.left * image.width).toInt();
        final top = (detection.boundingBox.top * image.height).toInt();
        final right = (detection.boundingBox.right * image.width).toInt();
        final bottom = (detection.boundingBox.bottom * image.height).toInt();

        img.Color boxColor;
        switch (detection.label.toLowerCase()) {
          case 'pothole':
            boxColor = img.ColorRgb8(255, 87, 34);
            break;
          case 'speed_breaker':
          case 'speed_breaker_unmarked':
            boxColor = img.ColorRgb8(255, 193, 7);
            break;
          case 'obstacle':
            boxColor = img.ColorRgb8(244, 67, 54);
            break;
          default:
            boxColor = img.ColorRgb8(33, 150, 243);
        }

        final thickness = 4;
        
        // Draw box lines
        img.drawRect(image, x1: left, y1: top, x2: right, y2: top + thickness, color: boxColor);
        img.drawRect(image, x1: left, y1: bottom - thickness, x2: right, y2: bottom, color: boxColor);
        img.drawRect(image, x1: left, y1: top, x2: left + thickness, y2: bottom, color: boxColor);
        img.drawRect(image, x1: right - thickness, y1: top, x2: right, y2: bottom, color: boxColor);

        // Draw label
        final label = '${detection.label} ${(detection.confidence * 100).toStringAsFixed(1)}%';
        final labelHeight = 30;
        final labelWidth = label.length * 12;
        
        img.drawRect(image, x1: left, y1: top - labelHeight, x2: left + labelWidth, y2: top, color: boxColor);
        img.drawString(image, label, font: img.arial24, x: left + 5, y: top - labelHeight + 5, color: img.ColorRgb8(255, 255, 255));
      }

      // Save the annotated image
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final directory = await getApplicationDocumentsDirectory();
      final annotatedPath = '${directory.path}/detection_$timestamp.jpg';
      
      final annotatedFile = File(annotatedPath);
      await annotatedFile.writeAsBytes(img.encodeJpg(image, quality: 90));

      debugPrint('✅ Detection image saved: $annotatedPath');
      return annotatedPath;
    } catch (e) {
      debugPrint('❌ Failed to save detection image: $e');
      rethrow;
    }
  }
}
