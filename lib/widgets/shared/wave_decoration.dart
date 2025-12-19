/// Widget dekorasi wave/gelombang untuk bagian bawah halaman
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class WaveDecoration extends StatelessWidget {
  final double height;

  const WaveDecoration({
    super.key,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: WavePainter(),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Gradient paint untuk wave
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primaryGreen.withValues(alpha: 0.8),
        AppColors.accentGreen,
        AppColors.accentYellow.withValues(alpha: 0.6),
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Mulai dari kiri bawah
    path.moveTo(0, size.height);

    // Wave pertama
    path.lineTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.3,
      size.width * 0.5,
      size.height * 0.5,
    );

    // Wave kedua
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.4,
    );

    // Tutup path
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Layer kedua wave
    final paint2 = Paint()
      ..color = AppColors.primaryGreen.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.8);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.5,
      size.width * 0.6,
      size.height * 0.7,
    );
    path2.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.85,
      size.width,
      size.height * 0.6,
    );
    path2.lineTo(size.width, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
