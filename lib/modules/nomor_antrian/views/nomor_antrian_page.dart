// Nomor Antrian Page - Screen 4: Menampilkan nomor antrian hasil
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_assets.dart';
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

          return Column(
            children: [
              // Main content - scrollable area
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile
                          ? AppSizes.paddingS
                          : AppSizes.paddingM,
                      vertical: isMobile
                          ? AppSizes.paddingS
                          : AppSizes.paddingM,
                    ),
                    child: Center(
                      child: ContentConstraint(
                        maxWidth: AppSizes.maxCardWidth,
                        child: CustomCard(
                          padding: EdgeInsets.all(
                            isMobile ? AppSizes.paddingS : AppSizes.paddingM,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header dengan logo dan title
                              _buildHeader(isMobile),
                              // Label Nomor Antrian
                              Text(
                                AppStrings.nomorAntrian,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.grey,
                                  fontSize: isMobile ? 12 : 14,
                                ),
                              ),

                              const SizedBox(height: 2),

                              // Nomor Antrian Besar
                              Text(
                                controller.queueNumber,
                                style: AppTextStyles.queueNumber.copyWith(
                                  fontSize: isMobile ? 42 : 56,
                                ),
                              ),

                              // Estimasi
                              Column(
                                children: [
                                  Text(
                                    AppStrings.estimasi,
                                    style: AppTextStyles.label.copyWith(
                                      fontSize: isMobile ? 11 : 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 12 : 16,
                                      vertical: isMobile ? 10 : 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        // Jam dipanggil (bold)
                                        Text(
                                          controller.estimasi.split('\n')[0],
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.heading3.copyWith(
                                            fontSize: isMobile ? 16 : 20,
                                            color: AppColors.primaryGreen,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // Penjelasan detail
                                        Text(
                                          controller.estimasi.split('\n').skip(1).join('\n'),
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontSize: isMobile ? 11 : 13,
                                            color: AppColors.textPrimary,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: isMobile
                                    ? AppSizes.paddingS
                                    : AppSizes.paddingM,
                              ),

                              // Badge Poli
                              _buildPoliBadge(isMobile),

                              // Divider
                              const Divider(color: AppColors.greyLight),

                              SizedBox(
                                height: isMobile
                                    ? AppSizes.paddingS
                                    : AppSizes.paddingM,
                              ),

                              // Data Pasien
                              _buildDataRow(
                                'Nama Lengkap',
                                controller.nama,
                                isMobile,
                              ),
                              const SizedBox(height: AppSizes.paddingS),
                              _buildDataRow(
                                'Jenis Kelamin',
                                controller.jenisKelamin,
                                isMobile,
                              ),
                              const SizedBox(height: AppSizes.paddingS),
                              _buildDataRow(
                                'Usia',
                                '${controller.usia} tahun',
                                isMobile,
                              ),

                              SizedBox(
                                height: isMobile
                                    ? AppSizes.paddingM
                                    : AppSizes.paddingL,
                              ),

                              // Button Kembali ke Home
                              CustomButton(
                                text: 'Kembali ke Beranda',
                                onPressed: controller.goToHome,
                                width: isMobile ? 160 : 250,
                                height: isMobile ? 30 : 40,
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
              WaveDecoration(height: 75),
            ],
          );
        },
      ),
    );
  }

  // Header dengan logo dan title
  Widget _buildHeader(bool isMobile) {
    final logoSize = isMobile ? 50.0 : 65.0;

    return Column(
      children: [
        // Logo dari asset
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: Image.asset(
            AppAssets.logo,
            width: logoSize,
            height: logoSize,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(
                Icons.local_hospital,
                color: AppColors.white,
                size: isMobile ? 26 : 34,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          AppStrings.appName,
          style: AppTextStyles.navbarTitle.copyWith(
            fontSize: isMobile ? 11 : 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Badge poli
  Widget _buildPoliBadge(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSizes.paddingS : AppSizes.paddingM,
        vertical: isMobile ? 6 : AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Text(
        controller.poli.toUpperCase(),
        style: AppTextStyles.buttonMedium.copyWith(
          fontSize: isMobile ? 11 : 13,
        ),
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
          style: AppTextStyles.label.copyWith(fontSize: isMobile ? 11 : 13),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 13 : 15,
          ),
        ),
      ],
    );
  }
}
