/// Widget hexagon untuk ilustrasi medis
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';

class HexagonImage extends StatelessWidget {
  final double size;

  const HexagonImage({
    super.key,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: HexagonPainter(),
        child: Center(
          child: Icon(
            Icons.local_hospital,
            size: size * 0.4,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryGreen,
          AppColors.accentGreen,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Shadow
    final shadowPaint = Paint()
      ..color = AppColors.shadowColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = _createHexagonPath(size);
    
    // Draw shadow
    canvas.save();
    canvas.translate(5, 5);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Draw hexagon
    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = AppColors.primaryGreen.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(path, borderPaint);
  }

  Path _createHexagonPath(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2 * 0.9;

    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
