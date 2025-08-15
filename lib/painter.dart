import 'dart:math';
import 'dart:ui';

import 'package:colortouch/drawline.dart';
import 'package:flutter/material.dart';

class SymmetryPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final List<Offset> currentPoints;
  final int symmetry;
  final Color currentColor;
  final double currentStrokeWidth;

  SymmetryPainter(
      this.lines,
      this.currentPoints,
      this.symmetry,
      this.currentColor,
      this.currentStrokeWidth,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    void drawSymmetry(List<Offset> points, Color color, double width) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < symmetry; i++) {
        final angle = (2 * pi / symmetry) * i;
        final matrix = Matrix4.identity()
          ..translate(center.dx, center.dy)
          ..rotateZ(angle)
          ..translate(-center.dx, -center.dy);

        final path = Path();
        for (int j = 0; j < points.length - 1; j++) {
          final p1 = MatrixUtils.transformPoint(matrix, points[j]);
          final p2 = MatrixUtils.transformPoint(matrix, points[j + 1]);
          path.moveTo(p1.dx, p1.dy);
          path.lineTo(p2.dx, p2.dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // Draw old lines
    for (var line in lines) {
      drawSymmetry(line.points, line.color, line.strokeWidth);
    }

    // Draw the current line being drawn
    if (currentPoints.isNotEmpty) {
      drawSymmetry(currentPoints, currentColor, currentStrokeWidth);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
