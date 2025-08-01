import 'dart:math';

import 'package:flutter/material.dart';

class SymmetryPainter extends CustomPainter {
  final List<List<Offset>> lines;
  final int symmetry;
  final Color color;
  final double strokeWidth;

  SymmetryPainter(this.lines, this.symmetry, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var line in lines) {
      for (int i = 0; i < symmetry; i++) {
        final angle = (2 * pi / symmetry) * i;
        final matrix = Matrix4.identity()
          ..translate(center.dx, center.dy)
          ..rotateZ(angle)
          ..translate(-center.dx, -center.dy);

        final path = Path();
        for (int j = 0; j < line.length - 1; j++) {
          final p1 = MatrixUtils.transformPoint(matrix, line[j]);
          final p2 = MatrixUtils.transformPoint(matrix, line[j + 1]);
          path.moveTo(p1.dx, p1.dy);
          path.lineTo(p2.dx, p2.dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}