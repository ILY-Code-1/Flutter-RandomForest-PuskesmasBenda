/// Landing Page - Screen 1: Hero dengan ilustrasi hexagon dan wave decoration
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../widgets/shared/navbar.dart';
import '../../../widgets/shared/wave_decoration.dart';
import '../../../widgets/shared/hexagon_image.dart';
import '../../../widgets/shared/custom_button.dart';
import '../../../widgets/shared/responsive_layout.dart';
import '../controllers/landing_controller.dart';

class LandingPage extends GetView<LandingController> {
  const LandingPage({super.key});

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
              // Main content
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      // Navbar
                      const AppNavbar(),

                      // Hero Section
                      ContentConstraint(
                        maxWidth: AppSizes.maxContentWidth,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? AppSizes.paddingM : AppSizes.paddingXL,
                        ),
                        child: SizedBox(
                          height: constraints.maxHeight * 0.7,
                          child: isDesktop
                              ? _buildDesktopHero()
                              : _buildMobileHero(isMobile),
                        ),
                      ),

                      // Spacer untuk wave
                      SizedBox(height: isMobile ? 50 : 100),
                    ],
                  ),
                ),
              ),

              // Wave decoration di bagian bawah
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: WaveDecoration(
                  height: isMobile ? AppSizes.waveHeightMobile : AppSizes.waveHeight,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Layout hero untuk desktop/tablet
  Widget _buildDesktopHero() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - Text and button
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.heroTitle,
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: AppSizes.paddingXL),
              CustomButton(
                text: AppStrings.ambilAntrian,
                onPressed: controller.goToPilihPoli,
                width: 220,
                height: 56,
              ),
            ],
          ),
        ),

        // Right side - Hexagon illustration
        const HexagonImage(size: AppSizes.hexagonSize),
      ],
    );
  }

  // Layout hero untuk mobile - flexible untuk ukuran layar kecil
  Widget _buildMobileHero(bool isMobile) {
    final hexagonSize = isMobile ? 150.0 : AppSizes.hexagonSizeMobile;
    
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hexagon illustration
          HexagonImage(size: hexagonSize),
          const SizedBox(height: AppSizes.paddingL),

          // Text
          Text(
            AppStrings.heroTitle,
            style: isMobile
                ? AppTextStyles.heading3
                : AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Button
          CustomButton(
            text: AppStrings.ambilAntrian,
            onPressed: controller.goToPilihPoli,
            width: isMobile ? 160 : 200,
            height: isMobile ? 44 : 52,
          ),
        ],
      ),
    );
  }
}
