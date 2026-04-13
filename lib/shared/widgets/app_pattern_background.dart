import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';

class AppPatternBackground extends StatelessWidget {
  const AppPatternBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final alpha = AppColors.isDark ? 0.055 : 0.022;
    return IgnorePointer(
      child: CustomPaint(
        painter: _AppPatternPainter(
          color: AppColors.primary.withValues(alpha: alpha),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _AppPatternPainter extends CustomPainter {
  const _AppPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cell = 96.0;
    const centerOffset = cell / 2;
    for (double x = -cell; x < size.width + cell; x += cell) {
      for (double y = -cell; y < size.height + cell; y += cell) {
        final center = Offset(x + centerOffset, y + centerOffset);
        stroke.strokeWidth = 1.4;
        canvas.drawCircle(center, 18, stroke);
        stroke.strokeWidth = 1.0;
        canvas.drawCircle(center, 13, stroke);
        stroke.strokeWidth = 0.8;
        canvas.drawCircle(center, 8, stroke);

        final path = Path()
          ..moveTo(x + 4, y + 4)
          ..quadraticBezierTo(x + 14, y + 14, x + 4, y + 24)
          ..moveTo(x + cell - 4, y + 4)
          ..quadraticBezierTo(x + cell - 14, y + 14, x + cell - 4, y + 24)
          ..moveTo(x + 4, y + cell - 4)
          ..quadraticBezierTo(x + 14, y + cell - 14, x + 4, y + cell - 24)
          ..moveTo(x + cell - 4, y + cell - 4)
          ..quadraticBezierTo(
            x + cell - 14,
            y + cell - 14,
            x + cell - 4,
            y + cell - 24,
          );
        canvas.drawPath(path, stroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AppPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
