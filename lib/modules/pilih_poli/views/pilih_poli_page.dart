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
import '../../../core/constants/app_assets.dart';
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
                            ? AppSizes.paddingL
                            : AppSizes.paddingXL,
                      ),

                      // Header section dengan icon
                      _buildHeaderSection(isMobile),

                      SizedBox(
                        height: isMobile
                            ? AppSizes.paddingXL
                            : AppSizes.paddingXXL,
                      ),

                      // Poli Cards
                      ContentConstraint(
                        maxWidth: AppSizes.maxContentWidth,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile
                              ? AppSizes.paddingM
                              : AppSizes.paddingXL,
                        ),
                        child: isDesktop
                            ? _buildDesktopCards(isMobile)
                            : _buildMobileCards(isMobile),
                      ),

                      SizedBox(
                        height: isMobile
                            ? AppSizes.paddingXL
                            : AppSizes.paddingXXL,
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

                      const SizedBox(height: AppSizes.paddingXXL),
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
    final logoSize = isMobile ? 70.0 : 90.0;

    return Column(
      children: [
        // Logo dari asset dengan shadow
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 20 : 25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isMobile ? 20 : 25),
            child: Image.asset(
              AppAssets.logo,
              width: logoSize,
              height: logoSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryGreen, AppColors.accentGreen],
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 20 : 25),
                ),
                child: Icon(
                  Icons.local_hospital_rounded,
                  color: AppColors.white,
                  size: isMobile ? 36 : 46,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: isMobile ? AppSizes.paddingM : AppSizes.paddingL),

        // Title
        Text(
          AppStrings.pilihPoli,
          style: isMobile ? AppTextStyles.heading3 : AppTextStyles.heading2,
        ),
        const SizedBox(height: AppSizes.paddingS),

        // Subtitle
        Text(
          'Pilih layanan kesehatan yang Anda butuhkan',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.grey,
            fontSize: isMobile ? 14 : 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Layout card untuk desktop - horizontal
  Widget _buildDesktopCards(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.poliList.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          child: _buildPoliCard(index, isDesktop: true, isMobile: isMobile),
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
          padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
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
            width: isDesktop ? 220 : double.infinity,
            height: isDesktop ? 240 : (isMobile ? 100 : 120),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              border: Border.all(
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primaryGreen.withValues(alpha: 0.25)
                      : AppColors.shadowColor,
                  blurRadius: isSelected ? 20 : 10,
                  offset: Offset(0, isSelected ? 8 : 4),
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
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon dengan gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [AppColors.primaryGreen, AppColors.accentGreen]
                    : gradientColors,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      (isSelected ? AppColors.primaryGreen : gradientColors[0])
                          .withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(iconData, size: 40, color: AppColors.white),
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Nama poli
          Flexible(
            child: Text(
              poli['name'],
              style: AppTextStyles.cardTitle.copyWith(
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),

          // Description
          Flexible(
            child: Text(
              _getPoliDescription(poli['code']),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey,
                fontSize: 12,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGreen,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Dipilih',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 12,
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
      padding: EdgeInsets.all(isMobile ? AppSizes.paddingM : AppSizes.paddingL),
      child: Row(
        children: [
          // Icon dengan gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isMobile ? 56 : 70,
            height: isMobile ? 56 : 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [AppColors.primaryGreen, AppColors.accentGreen]
                    : gradientColors,
              ),
              borderRadius: BorderRadius.circular(isMobile ? 14 : 18),
              boxShadow: [
                BoxShadow(
                  color:
                      (isSelected ? AppColors.primaryGreen : gradientColors[0])
                          .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              iconData,
              size: isMobile ? 28 : 36,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: isMobile ? AppSizes.paddingM : AppSizes.paddingL),

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
                      fontSize: isMobile ? 16 : 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    _getPoliDescription(poli['code']),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey,
                      fontSize: isMobile ? 12 : 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: isMobile ? AppSizes.paddingS : AppSizes.paddingM),

          // Check icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.greyLight.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSelected ? Icons.check : Icons.arrow_forward_ios,
              color: isSelected ? AppColors.white : AppColors.grey,
              size: isSelected ? 18 : 14,
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
