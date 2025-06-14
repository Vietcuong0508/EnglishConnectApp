// path_painter.dart
import 'dart:math';
import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  final List<Offset> points;
  final Offset? currentDrag;
  final Color lineColor;
  final Color shadowColor;
  final Color dotColor;
  final Color dotBorderColor;

  PathPainter(
    this.points,
    this.currentDrag, {
    required this.lineColor,
    required this.shadowColor,
    required this.dotColor,
    required this.dotBorderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty && currentDrag == null) return;

    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [lineColor, lineColor.withOpacity(0.8)],
          ).createShader(
            Rect.fromPoints(
              points.isNotEmpty ? points.first : (currentDrag ?? Offset.zero),
              currentDrag ?? (points.isNotEmpty ? points.last : Offset.zero),
            ),
          )
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final shadowPaint =
        Paint()
          ..color = shadowColor
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], shadowPaint);
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    if (points.isNotEmpty && currentDrag != null) {
      canvas.drawLine(points.last, currentDrag!, shadowPaint);
      canvas.drawLine(points.last, currentDrag!, paint);
    }

    final dotPaint =
        Paint()
          ..color = dotColor
          ..style = PaintingStyle.fill;

    final dotBorderPaint =
        Paint()
          ..color = dotBorderColor
          ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final pulseRadius =
          6 + sin(DateTime.now().millisecondsSinceEpoch / 200.0 + i) * 2;
      canvas.drawCircle(points[i], pulseRadius, dotBorderPaint);
      canvas.drawCircle(points[i], pulseRadius - 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.currentDrag != currentDrag;
}
