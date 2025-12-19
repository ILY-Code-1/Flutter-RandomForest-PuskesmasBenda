// Nomor Antrian Page - Screen 4: Menampilkan nomor antrian hasil
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../widgets/shared/wave_decoration.dart';
import '../../../widgets/shared/custom_card.dart';
import '../../../widgets/shared/custom_button.dart';
import '../../../widgets/shared/responsive_layout.dart';
import '../controllers/nomor_antrian_controller.dart';

class NomorAntrianPage extends GetView<NomorAntrianController> {
  const NomorAntrianPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < AppSizes.mobileBreakpoint;
          final waveHeight = isMobile ? AppSizes.waveHeightMobile : AppSizes.waveHeight;

          return Column(
            children: [
              // Main content - scrollable area
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? AppSizes.paddingM : AppSizes.paddingXL,
                      vertical: AppSizes.paddingXL,
                    ),
                    child: Center(
                      child: ContentConstraint(
                        maxWidth: AppSizes.maxCardWidth,
                        child: CustomCard(
                          padding: EdgeInsets.all(
                            isMobile ? AppSizes.paddingL : AppSizes.paddingXL,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header dengan logo dan title
                              _buildHeader(isMobile),

                              SizedBox(height: isMobile ? AppSizes.paddingL : AppSizes.paddingXL),

                              // Label Nomor Antrian
                              Text(
                                AppStrings.nomorAntrian,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.grey,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                              ),

                              const SizedBox(height: AppSizes.paddingS),

                              // Nomor Antrian Besar
                              Text(
                                controller.queueNumber,
                                style: AppTextStyles.queueNumber.copyWith(
                                  fontSize: isMobile ? 56 : 72,
                                ),
                              ),

                              const SizedBox(height: AppSizes.paddingM),

                              // Estimasi
                              Text(
                                AppStrings.estimasi,
                                style: AppTextStyles.label.copyWith(
                                  fontSize: isMobile ? 12 : 14,
                                ),
                              ),
                              const SizedBox(height: AppSizes.paddingXS),
                              Text(
                                controller.estimasi,
                                style: AppTextStyles.heading3.copyWith(
                                  fontSize: isMobile ? 20 : 24,
                                ),
                              ),

                              SizedBox(height: isMobile ? AppSizes.paddingM : AppSizes.paddingL),

                              // Badge Poli
                              _buildPoliBadge(isMobile),

                              SizedBox(height: isMobile ? AppSizes.paddingL : AppSizes.paddingXL),

                              // Divider
                              const Divider(color: AppColors.greyLight),

                              SizedBox(height: isMobile ? AppSizes.paddingM : AppSizes.paddingL),

                              // Data Pasien
                              _buildDataRow('Nama Lengkap', controller.nama, isMobile),
                              const SizedBox(height: AppSizes.paddingM),
                              _buildDataRow('Jenis Kelamin', controller.jenisKelamin, isMobile),
                              const SizedBox(height: AppSizes.paddingM),
                              _buildDataRow('Usia', '${controller.usia} tahun', isMobile),

                              SizedBox(height: isMobile ? AppSizes.paddingL : AppSizes.paddingXL),

                              // Button Kembali ke Home
                              CustomButton(
                                text: 'Kembali ke Beranda',
                                onPressed: controller.goToHome,
                                width: isMobile ? 180 : 220,
                                height: isMobile ? 44 : 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Wave decoration di bagian bawah - fixed position
              WaveDecoration(height: waveHeight),
            ],
          );
        },
      ),
    );
  }

  // Header dengan logo dan title
  Widget _buildHeader(bool isMobile) {
    return Column(
      children: [
        Container(
          width: isMobile ? 50 : 60,
          height: isMobile ? 50 : 60,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Icon(
            Icons.local_hospital,
            color: AppColors.white,
            size: isMobile ? 28 : 32,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Text(
          AppStrings.appName,
          style: AppTextStyles.navbarTitle.copyWith(fontSize: isMobile ? 12 : 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Badge poli
  Widget _buildPoliBadge(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSizes.paddingM : AppSizes.paddingL,
        vertical: isMobile ? AppSizes.paddingS : AppSizes.paddingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(AppSizes.radiusRounded),
      ),
      child: Text(
        controller.poli.toUpperCase(),
        style: AppTextStyles.buttonMedium.copyWith(fontSize: isMobile ? 12 : 14),
      ),
    );
  }

  // Row data pasien
  Widget _buildDataRow(String label, String value, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(fontSize: isMobile ? 12 : 14),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
      ],
    );
  }
}
