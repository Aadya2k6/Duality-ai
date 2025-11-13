import 'package:flutter/material.dart';
import 'package:sentineleye/models/detection_result.dart';

class BoundingBoxOverlay extends StatelessWidget {
  final List<DetectionResult> detections;
  final Size previewSize;

  const BoundingBoxOverlay({
    super.key,
    required this.detections,
    required this.previewSize,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: BoundingBoxPainter(
          detections: detections,
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
        ),
        child: Container(),
      );
}

class BoundingBoxPainter extends CustomPainter {
  final List<DetectionResult> detections;
  final bool isDarkMode;

  static const List<Color> _boxColors = [
    Color(0xFF34D399),
    Color(0xFF60A5FA),
    Color(0xFFFBBF24),
    Color(0xFFF87171),
    Color(0xFFA78BFA),
    Color(0xFFEC4899),
  ];

  BoundingBoxPainter({
    required this.detections,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var i = 0; i < detections.length; i++) {
      final detection = detections[i];
      final boxColor = _boxColors[i % _boxColors.length];

      final boxPaint = Paint()
        ..color = boxColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final box = detection.box;
      final left = box[0] * size.width;
      final top = box[1] * size.height;
      final right = box[2] * size.width;
      final bottom = box[3] * size.height;

      final rect = Rect.fromLTRB(left, top, right, bottom);
      canvas.drawRect(rect, boxPaint);

      final labelText =
          '${detection.label} ${(detection.score * 100).toStringAsFixed(0)}%';

      textPainter.text = TextSpan(
        text: labelText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.8),
              offset: const Offset(1, 1),
              blurRadius: 3,
            ),
          ],
        ),
      );

      textPainter.layout();

      final labelBackgroundPaint = Paint()
        ..color = boxColor.withValues(alpha: 0.9);

      final labelRect = Rect.fromLTWH(
        left,
        top - textPainter.height - 8,
        textPainter.width + 12,
        textPainter.height + 8,
      );

      final rrect =
          RRect.fromRectAndRadius(labelRect, const Radius.circular(4));
      canvas.drawRRect(rrect, labelBackgroundPaint);

      textPainter.paint(canvas, Offset(left + 6, top - textPainter.height - 4));
    }
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) =>
      detections != oldDelegate.detections;
}
