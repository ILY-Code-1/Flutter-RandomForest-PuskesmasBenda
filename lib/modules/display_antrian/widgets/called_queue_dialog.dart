/// Dialog untuk Menampilkan Antrian yang Dipanggil
/// Responsive design dengan animasi fade-in
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/queue_model.dart';

class CalledQueueDialog extends StatelessWidget {
  final QueueModel queue;

  const CalledQueueDialog({
    super.key,
    required this.queue,
  });

  @override
  Widget build(BuildContext context) {
    return _buildDialogContent(
      context: context,
      poli: queue.poli,
      nomorAntrian: queue.nomorAntrian,
      namaPasien: queue.namaPasien,
    );
  }
}

/// Dialog dari Map data (untuk Firebase realtime)
class CalledQueueDialogFromMap extends StatelessWidget {
  final Map<String, dynamic> data;

  const CalledQueueDialogFromMap({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return _buildDialogContent(
      context: context,
      poli: data['poli'] ?? '',
      nomorAntrian: data['nomorAntrian'] ?? '',
      namaPasien: data['namaPasien'] ?? '',
    );
  }
}

/// Shared dialog content builder with responsive design
Widget _buildDialogContent({
  required BuildContext context,
  required String poli,
  required String nomorAntrian,
  required String namaPasien,
}) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeOut,
    builder: (context, value, child) {
      return Opacity(
        opacity: value,
        child: Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: child,
        ),
      );
    },
    child: Container(
      color: Colors.white.withValues(alpha: 0.98),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive sizes based on screen height
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;
          
          // Responsive sizing factors
          final iconSize = (screenHeight * 0.08).clamp(60.0, 100.0);
          final headerFontSize = (screenHeight * 0.028).clamp(18.0, 28.0);
          final poliFontSize = (screenHeight * 0.038).clamp(24.0, 36.0);
          final queueNumberFontSize = (screenHeight * 0.12).clamp(60.0, 120.0);
          final nameFontSize = (screenHeight * 0.032).clamp(20.0, 32.0);
          final callTextFontSize = (screenHeight * 0.024).clamp(16.0, 24.0);
          
          // Responsive spacing
          final smallSpacing = screenHeight * 0.02;
          final mediumSpacing = screenHeight * 0.03;
          final largeSpacing = screenHeight * 0.04;
          
          // Responsive padding for queue number container
          final queuePaddingH = (screenWidth * 0.06).clamp(40.0, 80.0);
          final queuePaddingV = (screenHeight * 0.04).clamp(20.0, 40.0);
          
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.05,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon panggilan dengan animasi pulse
                    _PulsingIcon(size: iconSize),
                    SizedBox(height: smallSpacing),
                    
                    // Text "PANGGILAN ANTRIAN"
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'PANGGILAN ANTRIAN',
                        style: TextStyle(
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    SizedBox(height: mediumSpacing),
                    
                    // Poli name
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          poli.toUpperCase(),
                          style: TextStyle(
                            fontSize: poliFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: largeSpacing),
                    
                    // Queue number - main focus
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth * 0.8,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: queuePaddingH,
                        vertical: queuePaddingV,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          nomorAntrian,
                          style: TextStyle(
                            fontSize: queueNumberFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: mediumSpacing),
                    
                    // Patient name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          namaPasien,
                          style: TextStyle(
                            fontSize: nameFontSize,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(height: smallSpacing),
                    
                    // Call text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Silakan menuju ke loket pelayanan',
                          style: TextStyle(
                            fontSize: callTextFontSize,
                            color: AppColors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

/// Animated pulsing icon widget
class _PulsingIcon extends StatefulWidget {
  final double size;

  const _PulsingIcon({required this.size});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.campaign,
              size: widget.size * 0.6,
              color: Colors.orange,
            ),
          ),
        );
      },
    );
  }
}
