// Pilih Poli Page - Screen 2: Pilih poli dengan desain menarik
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../widgets/shared/navbar.dart';
import '../../../widgets/shared/custom_button.dart';
import '../../../widgets/shared/responsive_layout.dart';
import '../controllers/pilih_poli_controller.dart';

class PilihPoliPage extends GetView<PilihPoliController> {
  const PilihPoliPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= AppSizes.tabletBreakpoint;
          final isMobile = constraints.maxWidth < AppSizes.mobileBreakpoint;

          return Stack(
            children: [
              // Decorative circles background
              ..._buildDecorations(constraints),

              // Main content
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      const AppNavbar(),
                      SizedBox(
                        height: isMobile
                            ? AppSizes.paddingM
                            : AppSizes.paddingL,
                      ),

                      // Header section dengan icon
                      _buildHeaderSection(isMobile),

                      SizedBox(
                        height: isMobile
                            ? AppSizes.paddingL
                            : AppSizes.paddingXL,
                      ),

                      // Poli Cards
                      ContentConstraint(
                        maxWidth: AppSizes.maxContentWidth,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile
                              ? AppSizes.paddingS
                              : AppSizes.paddingM,
                        ),
                        child: isDesktop
                            ? _buildDesktopCards(isMobile)
                            : _buildMobileCards(isMobile),
                      ),

                      SizedBox(
                        height: isMobile
                            ? AppSizes.paddingM
                            : AppSizes.paddingL,
                      ),

                      // Button Selanjutnya dengan animasi
                      Obx(
                        () => AnimatedScale(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          scale: controller.isPoliSelected ? 1.0 : 0.95,
                          child: CustomButton(
                            text: AppStrings.selanjutnya,
                            onPressed: controller.goToIsiForm,
                            width: isMobile ? 180 : 220,
                            height: isMobile ? 48 : 56,
                            backgroundColor: controller.isPoliSelected
                                ? AppColors.primaryGreen
                                : AppColors.grey,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: isMobile
                            ? AppSizes.paddingL
                            : AppSizes.paddingXL,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Decorative background elements
  List<Widget> _buildDecorations(BoxConstraints constraints) {
    return [
      // Circle kanan atas
      Positioned(
        top: -50,
        right: -50,
        child: _buildDecorativeCircle(
          180,
          AppColors.accentGreen.withValues(alpha: 0.15),
        ),
      ),
      // Circle kiri bawah
      Positioned(
        bottom: -80,
        left: -80,
        child: _buildDecorativeCircle(
          250,
          AppColors.primaryGreen.withValues(alpha: 0.08),
        ),
      ),
      // Circle kecil kanan tengah
      Positioned(
        top: constraints.maxHeight * 0.4,
        right: 20,
        child: _buildDecorativeCircle(
          60,
          AppColors.accentYellow.withValues(alpha: 0.3),
        ),
      ),
      // Medical cross decorations
      Positioned(
        top: 150,
        left: 30,
        child: _buildMedicalCross(
          30,
          AppColors.primaryGreen.withValues(alpha: 0.1),
        ),
      ),
      Positioned(
        bottom: 200,
        right: 50,
        child: _buildMedicalCross(
          40,
          AppColors.accentGreen.withValues(alpha: 0.15),
        ),
      ),
    ];
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildMedicalCross(double size, Color color) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MedicalCrossPainter(color: color)),
    );
  }

  // Header section dengan logo dan subtitle
  Widget _buildHeaderSection(bool isMobile) {
    return Column(
      children: [
        SizedBox(height: isMobile ? AppSizes.paddingS : AppSizes.paddingM),

        // Title
        Text(
          AppStrings.pilihPoli,
          style: isMobile ? AppTextStyles.heading3 : AppTextStyles.heading2,
        ),
        const SizedBox(height: AppSizes.paddingXS),

        // Subtitle
        Text(
          'Pilih layanan kesehatan yang Anda butuhkan',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.grey,
            fontSize: isMobile ? 13 : 15,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Layout card untuk desktop - horizontal
  Widget _buildDesktopCards(bool isMobile) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          controller.poliList.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
            child: _buildPoliCard(index, isDesktop: true, isMobile: isMobile),
          ),
        ),
      ),
    );
  }

  // Layout card untuk mobile/tablet - vertical
  Widget _buildMobileCards(bool isMobile) {
    return Column(
      children: List.generate(
        controller.poliList.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
          child: _buildPoliCard(index, isDesktop: false, isMobile: isMobile),
        ),
      ),
    );
  }

  // Widget card untuk setiap poli dengan desain menarik
  Widget _buildPoliCard(
    int index, {
    bool isDesktop = false,
    bool isMobile = false,
  }) {
    final poli = controller.poliList[index];
    final iconData = _getIconData(poli['icon']);
    final gradientColors = _getGradientColors(index);

    return Obx(() {
      final isSelected = controller.selectedPoliIndex.value == index;

      return GestureDetector(
        onTap: () => controller.selectPoli(index),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          scale: isSelected ? 1.02 : 1.0,
          child: Container(
            width: isDesktop ? 185 : double.infinity,
            height: isDesktop ? 200 : (isMobile ? 90 : 110),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primaryGreen.withValues(alpha: 0.25)
                      : AppColors.shadowColor,
                  blurRadius: isSelected ? 16 : 8,
                  offset: Offset(0, isSelected ? 6 : 3),
                ),
              ],
            ),
            child: isDesktop
                ? _buildDesktopCardContent(
                    poli,
                    iconData,
                    gradientColors,
                    isSelected,
                    isMobile,
                  )
                : _buildMobileCardContent(
                    poli,
                    iconData,
                    gradientColors,
                    isSelected,
                    isMobile,
                  ),
          ),
        ),
      );
    });
  }

  // Content card untuk desktop - vertikal
  Widget _buildDesktopCardContent(
    Map<String, dynamic> poli,
    IconData iconData,
    List<Color> gradientColors,
    bool isSelected,
    bool isMobile,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon dengan gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [AppColors.primaryGreen, AppColors.accentGreen]
                    : gradientColors,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      (isSelected ? AppColors.primaryGreen : gradientColors[0])
                          .withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(iconData, size: 32, color: AppColors.white),
          ),
          const SizedBox(height: AppSizes.paddingM),

          // Nama poli
          Flexible(
            child: Text(
              poli['name'],
              style: AppTextStyles.cardTitle.copyWith(
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
                fontSize: 15,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppSizes.paddingXS),

          // Description
          Flexible(
            child: Text(
              _getPoliDescription(poli['code']),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey,
                fontSize: 11,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const Spacer(),

          // Selected indicator
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isSelected ? 1.0 : 0.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGreen,
                    size: 14,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Dipilih',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Content card untuk mobile - horizontal
  Widget _buildMobileCardContent(
    Map<String, dynamic> poli,
    IconData iconData,
    List<Color> gradientColors,
    bool isSelected,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? AppSizes.paddingS : AppSizes.paddingM),
      child: Row(
        children: [
          // Icon dengan gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isMobile ? 50 : 64,
            height: isMobile ? 50 : 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [AppColors.primaryGreen, AppColors.accentGreen]
                    : gradientColors,
              ),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              boxShadow: [
                BoxShadow(
                  color:
                      (isSelected ? AppColors.primaryGreen : gradientColors[0])
                          .withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              iconData,
              size: isMobile ? 26 : 32,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: isMobile ? AppSizes.paddingS : AppSizes.paddingM),

          // Text content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    poli['name'],
                    style: AppTextStyles.cardTitle.copyWith(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.textSecondary,
                      fontSize: isMobile ? 14 : 16,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    _getPoliDescription(poli['code']),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey,
                      fontSize: isMobile ? 11 : 12,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: isMobile ? AppSizes.paddingXS : AppSizes.paddingS),

          // Check icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.greyLight.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSelected ? Icons.check : Icons.arrow_forward_ios,
              color: isSelected ? AppColors.white : AppColors.grey,
              size: isSelected ? 16 : 12,
            ),
          ),
        ],
      ),
    );
  }

  // Get gradient colors berdasarkan index
  List<Color> _getGradientColors(int index) {
    switch (index) {
      case 0: // Poli Umum - Biru
        return [const Color(0xFF42A5F5), const Color(0xFF1E88E5)];
      case 1: // Poli Lansia - Hijau Tua
        return [const Color(0xFF66BB6A), const Color(0xFF43A047)];
      case 2: // Poli Anak - Kuning/Orange Cerah
        return [const Color(0xFFFFCA28), const Color(0xFFFFA726)];
      case 3: // Poli KIA - Pink
        return [const Color(0xFFF48FB1), const Color(0xFFEC407A)];
      case 4: // Poli Gigi - Purple
        return [const Color(0xFFAB47BC), const Color(0xFF8E24AA)];
      default:
        return [AppColors.primaryGreen, AppColors.accentGreen];
    }
  }

  // Get description berdasarkan kode poli
  String _getPoliDescription(String code) {
    switch (code) {
      case 'PU':
        return 'Layanan kesehatan umum';
      case 'PL':
        return 'Pelayanan kesehatan lansia';
      case 'PA':
        return 'Pelayanan kesehatan anak';
      case 'PK':
        return 'Ibu hamil & imunisasi';
      case 'PG':
        return 'Perawatan gigi & mulut';
      default:
        return 'Layanan kesehatan';
    }
  }

  // Get icon berdasarkan nama
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'elderly':
        return Icons.elderly_rounded;
      case 'child_care':
        return Icons.child_care_rounded;
      case 'pregnant_woman':
        return Icons.pregnant_woman_rounded;
      case 'dentistry':
        return Icons.sentiment_satisfied_alt_rounded;
      default:
        return Icons.local_hospital_rounded;
    }
  }
}

// Custom painter untuk medical cross decoration
class _MedicalCrossPainter extends CustomPainter {
  final Color color;

  _MedicalCrossPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final crossWidth = size.width * 0.35;
    final crossLength = size.width;

    // Horizontal bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: crossLength,
          height: crossWidth,
        ),
        Radius.circular(crossWidth / 2),
      ),
      paint,
    );

    // Vertical bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: crossWidth,
          height: crossLength,
        ),
        Radius.circular(crossWidth / 2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
