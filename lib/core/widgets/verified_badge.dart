import 'dart:math' as math;
import 'package:flutter/material.dart';

enum VerifiedBadgeType {
  none(0, 'Off', Colors.transparent),
  skyBlue(1, 'Sky', Color(0xFF0095F6)),
  black(2, 'Black', Color(0xFF18181B)),
  violet(3, 'Violet', Color(0xFF8B5CF6));

  const VerifiedBadgeType(this.id, this.label, this.color);
  final int id;
  final String label;
  final Color color;

  static VerifiedBadgeType fromId(int id) {
    return switch (id) {
      1 => VerifiedBadgeType.skyBlue,
      2 => VerifiedBadgeType.black,
      3 => VerifiedBadgeType.violet,
      _ => VerifiedBadgeType.none,
    };
  }
}

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({
    super.key,
    required this.color,
    this.size = 18,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _VerifiedBadgePainter(color: color),
    );
  }
}

class _VerifiedBadgePainter extends CustomPainter {
  const _VerifiedBadgePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    final bgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw the 12-lobed scalloped rosette of Instagram verified badge
    final path = Path();
    const int lobes = 12;
    final double rMax = w * 0.48;
    final double rMin = w * 0.40;

    for (var i = 0; i < lobes * 2; i++) {
      final double angle = (i * math.pi) / lobes - (math.pi / 2);
      final double r = (i % 2 == 0) ? rMax : rMin;
      final double x = center.dx + r * math.cos(angle);
      final double y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, bgPaint);

    // Draw the crisp white checkmark inside
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, w * 0.13)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final checkPath = Path();
    checkPath.moveTo(w * 0.30, h * 0.50);
    checkPath.lineTo(w * 0.43, h * 0.64);
    checkPath.lineTo(w * 0.70, h * 0.35);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant _VerifiedBadgePainter oldDelegate) =>
      oldDelegate.color != color;
}
