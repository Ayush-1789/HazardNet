import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Utility class for generating custom map markers
class MapMarkerGenerator {
  /// Cache for generated markers to avoid regenerating same markers
  static final Map<String, BitmapDescriptor> _markerCache = {};

  /// Generate a circular marker with an icon inside
  /// 
  /// [icon] - The icon to display inside the circle
  /// [color] - The background color of the circle
  /// [size] - The size of the marker in pixels (default: 100)
  /// [iconColor] - The color of the icon (default: white)
  static Future<BitmapDescriptor> generateCircularMarker({
    required IconData icon,
    required Color color,
    double size = 100,
    Color iconColor = Colors.white,
    bool isVerified = false,
  }) async {
    // Create cache key
    final cacheKey = '${icon.codePoint}_${color.value}_${size}_${iconColor.value}_$isVerified';
    
    // Return cached marker if available
    if (_markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }

    // Create a picture recorder to draw the marker
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;

    // Draw outer circle (background)
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2,
      paint,
    );

    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2,
      borderPaint,
    );

    // Draw icon in the center
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size * 0.5,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: iconColor,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    // If verified, add a checkmark badge
    if (isVerified) {
      final badgeSize = size * 0.3;
      final badgePaint = Paint()..color = Colors.green;
      final badgeX = size - badgeSize / 2;
      final badgeY = badgeSize / 2;

      // Draw green circle for verified badge
      canvas.drawCircle(
        Offset(badgeX, badgeY),
        badgeSize / 2,
        badgePaint,
      );

      // Draw white checkmark
      final checkPainter = TextPainter(textDirection: TextDirection.ltr);
      checkPainter.text = TextSpan(
        text: String.fromCharCode(Icons.check.codePoint),
        style: TextStyle(
          fontSize: badgeSize * 0.6,
          fontFamily: Icons.check.fontFamily,
          color: Colors.white,
        ),
      );
      checkPainter.layout();
      checkPainter.paint(
        canvas,
        Offset(
          badgeX - checkPainter.width / 2,
          badgeY - checkPainter.height / 2,
        ),
      );
    }

    // Convert the picture to an image
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    if (bytes == null) {
      throw Exception('Failed to generate marker image');
    }

    // Create bitmap descriptor from bytes
    final bitmapDescriptor = BitmapDescriptor.fromBytes(
      bytes.buffer.asUint8List(),
    );

    // Cache the generated marker
    _markerCache[cacheKey] = bitmapDescriptor;

    return bitmapDescriptor;
  }

  /// Get the appropriate icon for a hazard type
  static IconData getHazardIcon(String type) {
    switch (type) {
      case 'pothole':
        return Icons.crisis_alert;
      case 'speed_breaker':
      case 'speed_breaker_unmarked':
        return Icons.speed;
      case 'obstacle':
        return Icons.block;
      case 'closed_road':
        return Icons.do_not_disturb_on;
      case 'lane_blocked':
        return Icons.warning;
      default:
        return Icons.warning;
    }
  }

  /// Clear the marker cache (useful for memory management)
  static void clearCache() {
    _markerCache.clear();
  }
}
