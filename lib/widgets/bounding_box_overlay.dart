import 'package:flutter/material.dart';
import 'package:event_safety_app/data/services/tflite_service.dart';
import 'package:event_safety_app/core/constants/model_config.dart';

/// Widget that draws bounding boxes over camera preview
class BoundingBoxOverlay extends StatelessWidget {
  final List<Detection> detections;
  final Size previewSize;
  final Size screenSize;

  const BoundingBoxOverlay({
    Key? key,
    required this.detections,
    required this.previewSize,
    required this.screenSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (detections.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: BoundingBoxPainter(
        detections: detections,
        previewSize: previewSize,
        screenSize: screenSize,
      ),
      child: Container(),
    );
  }
}

/// CustomPainter to draw bounding boxes and labels
class BoundingBoxPainter extends CustomPainter {
  final List<Detection> detections;
  final Size previewSize;
  final Size screenSize;

  BoundingBoxPainter({
    required this.detections,
    required this.previewSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var detection in detections) {
      _drawBoundingBox(canvas, size, detection);
    }
  }

  void _drawBoundingBox(Canvas canvas, Size size, Detection detection) {
    // Calculate scale factors
    final scaleX = size.width / previewSize.width;
    final scaleY = size.height / previewSize.height;
    
    // Convert normalized coordinates to screen coordinates
    final left = detection.boundingBox.left * previewSize.width * scaleX;
    final top = detection.boundingBox.top * previewSize.height * scaleY;
    final right = detection.boundingBox.right * previewSize.width * scaleX;
    final bottom = detection.boundingBox.bottom * previewSize.height * scaleY;
    
    final rect = Rect.fromLTRB(left, top, right, bottom);

    // Get color for this class
    final color = Color(ModelConfig.getColorForClass(detection.label));

    // Draw semi-transparent fill
    final fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRect(rect, borderPaint);

    // Draw corner indicators (for better visibility)
    _drawCorners(canvas, rect, color);

    // Draw label background
    final label = detection.label.toUpperCase();
    final confidence = (detection.confidence * 100).toStringAsFixed(0);
    final text = '$label $confidence%';

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 4,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Position label at top of box or above if space allows
    double labelTop = top - textPainter.height - 8;
    if (labelTop < 0) {
      labelTop = top + 4; // Place inside box if no space above
    }

    // Draw label background
    final labelBgRect = Rect.fromLTWH(
      left,
      labelTop,
      textPainter.width + 16,
      textPainter.height + 8,
    );

    final labelBgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelBgRect, const Radius.circular(4)),
      labelBgPaint,
    );

    // Draw text
    textPainter.paint(
      canvas,
      Offset(left + 8, labelTop + 4),
    );
  }

  void _drawCorners(Canvas canvas, Rect rect, Color color) {
    final cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 20.0;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.top + cornerLength),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - cornerLength, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.bottom - cornerLength),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - cornerLength, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return detections != oldDelegate.detections;
  }
}
